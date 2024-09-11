# Filesystem quotas
class common::storage::quota (
  Boolean $enable = false,
  Hash[Stdlib::Absolutepath, Struct[{
    user  => Optional[Hash[Eit_types::User, Eit_types::Storage::Quota]],
    group => Optional[Hash[Eit_types::Group, Eit_types::Storage::Quota]],
  }]] $quotas = {},
) inherits common::storage {

  $_install = $quotas.size > 0

  if $_install {
    # Package before 0.1.1 has a wrong PREFIX causing PAM to fail. Fixed in
    # https://gitlab.enableit.dk/obmondo/obmondo-disk-quotas/-/commit/4182a40b30a0b2a3e9edbb99934a043ccb320a8b.
    package::install('obmondo-disk-quotas', {
      ensure => 'latest',
    })

    $_config_dir = '/etc/obmondo/quotas.d'

    file { $_config_dir:
      ensure  => 'directory',
      purge   => true,
      recurse => true,
    }
  }

  File {
    require => if $_install {
      Package['obmondo-disk-quotas']
    },
  }

  $quotas.each |$_values| {
    [$_fs, $_config] = $_values
    $_escaped_fs = systemd_escape_path($_fs)

    $_config.each |$_quota_type, $_quotas| {
      $_config_lines = $_quotas.map |$_id, $_quota_config| {
        [
          $_id,
          $_quota_config['block_soft'],
          $_quota_config['block_hard'],
          $_quota_config['inode_soft'],
          $_quota_config['inode_hard'],
        ].join(' ')
      }.join("\n")

      file { "${_config_dir}/010_${_quota_type}_${_escaped_fs}.quota":
        ensure  => 'file',
        content => "${_config_lines}\n",
      }
    }
  }
}
