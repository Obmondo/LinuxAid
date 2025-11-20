# Cloudamize
class profile::software::cloudamize (
  Array[Eit_types::SimpleString] $__packages,

  Boolean               $enable       = $common::software::cloudamize::enable,
  Optional[String]      $customer_key = $common::software::cloudamize::customer_key,
  Eit_types::Noop_Value $noop_value   = $common::software::cloudamize::noop_value,
) {

  Exec {
    path        => [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    refreshonly => true,
    noop        => $noop_value,
    before => if $enable {
      Service['cloudamized']
    },
    subscribe => if $enable {
      Package[$__packages]
    },
  }
  File {
    noop => $noop_value,
  }
  File_line {
    noop => $noop_value,
  }
  Package {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }

  package { $__packages:
    ensure => ensure_present($enable),
  }

  file { '/usr/local/cloudamize/bin/customer_key':
    ensure  => ensure_file($enable),
    content => "${customer_key}\n",
    require => if $enable {
      Package[$__packages]
      },
    before  => if $enable {
      Service['cloudamized']
    },
  }

  if $enable {
    file_line { 'cloudamized no upgrade':
      ensure  => ensure_present($enable),
      path    => '/usr/local/cloudamize/bin/config.props',
      line    => 'no_upgrade=1',
      before  => Service['cloudamized'],
      require => Package[$__packages],
    }
  }

  # cloudamize spawns itself during postinstall; kill it so we can run it under
  # systemd
  exec { 'force kill cloudamize':
    command => 'pkill -f cloudamize && rm -f /var/lock/subsys/cloudamized || true',
  }

  exec { 'remove cloudamize from rc.d':
    command     => 'sed -ri -e "/cloudamize/d" /etc/rc.local /etc/rc.d/rc.local',
    onlyif      => 'grep -q cloudamize /etc/rc.local /etc/rc.d/rc.local',
    refreshonly => false,
  }

  service { 'cloudamized':
    ensure  => $enable,
    enable  => if $enable { true },
    before  => if !$enable {
      Package[$__packages]
    },
    require => if $enable {
      Package[$__packages]
    },
  }

  if !$enable {
    file { '/usr/local/cloudamize':
      ensure => absent,
      force  => true,
    }
  }
}
