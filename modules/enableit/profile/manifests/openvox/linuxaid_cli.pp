# Linuxaid-cli setup

# @summary Class for managing linuxaid-cli installation
#
# @param noop_value Eit_types::Noop_Value to enable no-operation mode.
#
class profile::openvox::linuxaid_cli (
  Eit_types::Noop_Value $noop_value = $common::openvox::noop_value,
) {
  $_version        = lookup('common::openvox::linuxaid_cli::version')
  $_checksum       = lookup('common::openvox::linuxaid_cli::checksums')
  $_install_method = lookup('common::openvox::linuxaid_cli::install_method')

  $_arch        = profile::arch()
  $_os_family   = $facts['os']['family']
  $_kernel      = $facts['kernel'].downcase
  $_init_system = $facts['init_system']

  $_notify_res = $_init_system ? {
    'sysvinit' => Cron['run-openvox'],
    default    => Systemd::Timer['run-openvox.timer', 'obmondo-system-update.timer'],
  }

  case $_install_method {
    'package': {
      $_linuxaid_cli_package_version = $_os_family ? {
        'Debian' => "v${_version}",
        'RedHat' => "v${_version}-1",
        'Suse'   => "v${_version}-1",
        default  => fail("Unsupported OS family: ${_os_family}. Try installing linuxaid-cli via archive install method"),
      }
      package { 'linuxaid-cli':
        ensure => $_linuxaid_cli_package_version,
        noop   => $noop_value,
        notify => $_notify_res,
      }
    }
    'archive': {
      archive { 'linuxaid-cli':
        ensure          => present,
        source          => "https://github.com/Obmondo/Linuxaid-cli/releases/download/v${_version}/linuxaid-cli_v${_version}_linux_${_arch}.tar.gz",
        extract         => true,
        extract_command => 'tar xzf %s linuxaid-cli',
        path            => "/tmp/linuxaid-cli_Linux_${_arch}.tar.gz",
        extract_path    => '/opt/obmondo/bin',
        checksum        => $_checksum[$_version],
        checksum_type   => 'sha256',
        cleanup         => true,
        noop            => $noop_value,
        notify          => $_notify_res,
      }
    }
    default: {
      info('Unsupported install method, please raise issue on github')
    }
  }

  ensure_resource('file', '/etc/default', {
    ensure => directory,
    noop   => $noop_value,
    mode   => '0755',
    owner  => 'root',
  })

  file { '/etc/default/linuxaid-cli':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    noop    => $noop_value,
    content => anything_to_ini({
      'PUPPETCERT'    => $facts['hostcert'],
      'PUPPETPRIVKEY' => $facts['hostprivkey'],
      'HOSTNAME'      => $trusted['certname'],
    }),
  }
}
