# @!visibility private
class rngd::config {

  $hwrng_device = $::rngd::hwrng_device

  case $facts['os']['family'] {
    'RedHat': {
      $options = delete_undef_values([
        $hwrng_device ? {
          undef   => undef,
          default => "-r ${hwrng_device}",
        },
      ])

      file { '/etc/sysconfig/rngd':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/sysconfig.erb"),
      }

      if $facts['os']['release']['major'] == '7' {

        $directory_seltype = $facts['os']['selinux']['enabled'] ? {
          true    => 'systemd_unit_file_t',
          default => undef,
        }

        $file_seltype = $facts['os']['selinux']['enabled'] ? {
          true    => 'rngd_unit_file_t',
          default => undef,
        }

        file { '/etc/systemd/system/rngd.service.d':
          ensure  => directory,
          owner   => 0,
          group   => 0,
          mode    => '0644',
          seltype => $directory_seltype,
        }

        ensure_resource('exec', 'systemctl daemon-reload', {
          refreshonly => true,
          path        => $::path,
        })

        file { '/etc/systemd/system/rngd.service.d/override.conf':
          ensure  => file,
          owner   => 0,
          group   => 0,
          mode    => '0644',
          content => file('rngd/override.conf'),
          seltype => $file_seltype,
          notify  => Exec['systemctl daemon-reload'],
        }
      }
    }
    'Debian': {
      file { '/etc/default/rng-tools':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/default.erb"),
      }
    }
    default: {
      # noop
    }
  }
}
