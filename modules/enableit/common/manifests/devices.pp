# @summary Class for managing common::devices
#
# @param devices Hash of device configurations. Defaults to empty hash.
#
# @param encrypted_devices Hash of encrypted device configurations. Defaults to empty hash.
#
# @param filesystems Hash of filesystem configurations. Defaults to empty hash.
#
class common::devices (
  Hash $devices = {},
  Hash $encrypted_devices = {},
  Hash $filesystems = {},
) {

  # we default to setting up LUKS only when we use encrypted devices
  $needs_encryption_scripts = !empty($encrypted_devices)

  # Install haveged only if we aren't virtual, or if we are on kvm or
  # vmware. You can use the script in https://security.stackexchange.com/a/34552
  # to check if haveged should work or not.
  $_install_haveged = $facts.dig('treat_as_physical') and $needs_encryption_scripts

  if $_install_haveged {
    package::install('haveged', {
      notify => Service['haveged'],
    })
  }

  package::install('obmondo-scripts-disk-encryption', {
    ensure => ensure_present($needs_encryption_scripts),
  })

  # We need to make sure that we have enough entropy to avoid hanging when
  # waiting for /dev/random; haveged can do this for us
  # https://gitlab.enableit.dk/obmondo/puppet/merge_requests/188/diffs#note_1452
  # "WE don't need haveged running it might be needed anyway for customer
  # apps. I'd prefer to only enable it, never disable"
  ensure_resource('service', 'haveged', {
    ensure => if $_install_haveged { 'running' },
    enable => $_install_haveged,
  })

  # HACK: Due to [1] we need to grant systemd access to proc.
  if $facts['selinux_enabled'] {
    selinux::module { 'systemctl_proc':
      ensure    => 'present',
      source_te => 'puppet:///modules/common/selinux/systemctl_proc.te',
      builder   => 'simple'
    }
  }

  $_conf_dir = lookup('common::setup::__conf_dir')

  if $devices.size > 0 or $encrypted_devices.size > 0 {
    file { "${_conf_dir}/luks":
      ensure => directory,
      mode   => '0500',
      owner  => root,
    }
  }

  $encrypted_devices.each |$k, $v| {
    common::device::encrypted_disk { $k:
      require => File["${_conf_dir}/luks"],
      *       => $v,
    }
  }

  $filesystems.each |$k, $v| {
    common::device::filesystem { $k:
      * => $v,
    }
  }
}
