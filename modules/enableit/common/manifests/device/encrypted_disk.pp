# @summary Class for managing the common::device::encrypted_disk resource
#
# @param device The absolute path to the device. This parameter is required.
#
# @param luks_key_service_url The URL for the LUKS key service. Defaults to undef.
#
# @param luks_key_service_headers Optional headers for the LUKS key service. Defaults to undef.
#
# @param luks_key The password for LUKS encryption. Defaults to undef.
#
# @param luks_key_size_b The size of the encryption key in bits. Defaults to 1024.
#
# @param pool_name The name of the ZFS pool, if applicable. Defaults to undef.
#
# @groups device device.
#
# @groups encryption luks_key, luks_key_size_b, luks_key_service_url, luks_key_service_headers.
#
# @groups pool pool_name.
#
define common::device::encrypted_disk (
  Stdlib::Absolutepath $device,
  Optional[Eit_types::URL] $luks_key_service_url          = undef,
  Optional[Hash[String,String]] $luks_key_service_headers = undef,
  Optional[Eit_types::Password] $luks_key                 = undef,
  Optional[Variant[
    Integer[512,512],
    Integer[1024,1024],
    Integer[2048,2048],
    Integer[4096,4096]]] $luks_key_size_b                 = 1024,
  Optional[Eit_types::SimpleString] $pool_name = undef
) {

  $_name = systemd_escape_path($device)

  $_service_alias_name = "disk@${name}.service"
  $_service_name = "encrypted_disk@${name}.service"

  $pgp_key_ids = lookup('common::settings::pgp_key_ids')

  confine(!($luks_key or $luks_key_service_url), '`luks_key` or `luks_key_service_url` must be set.')
  confine($luks_key_service_headers and !$luks_key_service_url,
    '`luks_key_service_headers` can only be used when `luks_key_service_url` is set.')
  confine(!$pgp_key_ids, 'A least one PGP public key ID needed for LUKS: `common::settings::pgp_key_ids`')

  # where to store encrypted luks keys, env file etc.
  $luks_conf_dir = "${common::setup::__conf_dir}/luks"
  $env_file = "${luks_conf_dir}/${name}.env"

  # Find a corresponding filesystem defined in hiera
  $_filesystems = lookup('common::devices::filesystems', Data, undef, {})

  # If we have a device under filesystems that match the name, then we can look
  # up the fs type
  $_filesystem_type = Array($_filesystems.filter |$fs, $opts| {
    $name in $opts['devices']
  }).dig(0, 1, 'fs_type')
  # The above requires a bit of an explanation: since we don't know the key value in the
  # hash we convert it to an array, take the first value and then the second value of that
  # (the hash values). `dig` returns `undef` when an item can't be found, so this works
  # (should work?) for all cases.

  $_unit_before = $_filesystem_type ? {
    'zfs' => [
      {'Before' => 'zfs-import-cache.service'},
      {'Before' => 'zfs-import-scan.service'},
      # {'Requires' => 'zfs-import-cache.service'},
      # {'Requires' => 'zfs-import-scan.service'},
      if $pool_name {
        {'PartOf' => "${pool_name}-pool.service"}
      },
    ].delete_undef_values,
    default => [],
  }

  $_unit = [
    {'Description'         => "Manage LUKS device ${device}"},
    {'After'               => 'network.target'},
    {'ConditionPathExists' => "${luks_conf_dir}/%i.env"}
  ] + $_unit_before

  # Create a systemd service for opening/closing the device
  common::services::systemd { $_service_name :
    ensure  => true,
    unit    => $_unit,
    service => {
      'Type'            => 'oneshot',
      'ExecStart'       => '/opt/obmondo/bin/luks.sh start %i',
      'ExecStop'        => '/opt/obmondo/bin/luks.sh stop %i',
      'EnvironmentFile' => "${luks_conf_dir}/%i.env",
      'RemainAfterExit' => 'yes',
      'ProtectHome'     => 'yes',
      'ProtectSystem'   => 'yes',
    },
    install => {
      'Alias'    => $_service_alias_name,
    },
    require => [File[$env_file]],
  }

  $_luks_key_service_headers = if $luks_key_service_headers {
    $luks_key_service_headers.map |$_header, $_value| {
      "'${_header}: ${_value}'"
    }.join(' ').then |$_headers| { "(${_headers})" }
  }

  $_pgp_target_pubkeys = join($pgp_key_ids, ' ')

  $luks_env = {
    'LUKS_DEVICE'              => $device,
    'LUKS_NAME'                => $_name,
    'LUKS_KEY'                 => $luks_key,
    'LUKS_KEY_SERVICE_URL'     => $luks_key_service_url,
    'LUKS_KEY_SIZE_B'          => $luks_key_size_b,
    'GPG_TARGET_PUBKEYS'       => $_pgp_target_pubkeys,
    'GPG_KEYSERVER'            => lookup('common::settings::pgp_keyserver'),
    'GNUPGHOME'                => $luks_conf_dir,
  }

  $_config_hash = hash_to_ini($luks_env, {
      quote      => "'",
      escape     => false,
      skip_undef => true,
  })

  # as we pass the service headers as a bash array we need to have this line in
  # the config without surrounding quotes
  $_config_content = "${_config_hash}\nLUKS_KEY_SERVICE_HEADERS=${_luks_key_service_headers}\n"

  file { $env_file:
    ensure  => present,
    content => $_config_content,
  }
}
