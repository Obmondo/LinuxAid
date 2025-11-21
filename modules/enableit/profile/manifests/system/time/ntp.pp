# NTP
class profile::system::time::ntp (
  Boolean                                     $manage     = $common::system::time::ntp::manage,
  Enum['chrony', 'ntpd', 'systemd-timesyncd'] $ntp_client = $common::system::time::ntp::ntp_client,
  Array[Stdlib::Host]                         $servers    = $common::system::time::ntp::servers,
  Eit_types::Noop_Value                       $noop_value = $common::system::time::ntp::noop_value,
) {

  $_enable_ntp = $facts.dig('treat_as_physical') and !($facts.dig('cloud', 'provider') == 'azure')

  File {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }

  case $ntp_client {
    'chrony': {
      package { 'chrony':
        ensure => 'latest',
        before => Service['chronyd'],
      }

      file { '/etc/chrony.conf':
        ensure  => 'file',
        content => epp('profile/system/time/ntp/chrony.conf.epp', {
          servers => $servers,
        }),
        before  => Service['chronyd'],
        notify  => Service['chronyd'],
      }

      profile::system::time::ntp::rtc { $ntp_client:
        service_name => chronyd,
      }
    }

    'ntpd': {
      class { 'ntp':
        service_enable => $_enable_ntp,
        service_ensure => ensure_service($_enable_ntp),
        servers        => $servers,
      }

      profile::system::time::ntp::rtc { $ntp_client:
        service_name => $ntp::service_name,
      }
    }

    'systemd-timesyncd': {

      $_uses_tmp_disk = $facts['partitions'].map |$_, $_options| { $_options.dig('mount') }.grep('/tmp').size >= 1
      $is_azure = $facts.dig('cloud', 'provider') == 'azure'
      $_cloud_init = lookup('common::system::cloud_init::manage', Boolean, undef, false)

      confine ($manage,
        $_uses_tmp_disk,
        $is_azure,
        !$_cloud_init,
        '/tmp is mounted as a partition, which would need cloud-init service to be running'
      )

      file { '/etc/systemd/timesyncd.conf':
        ensure  => 'file',
        content => "# MANAGED BY PUPPET; CAVEAT LECTOR
[Time]
NTP=${servers.join(' ')}\n",
        notify  => Service['systemd-timesyncd'],
      }

      file { '/etc/systemd/timesyncd.conf.d':
        ensure  => 'absent',
        purge   => true,
        force   => true,
        recurse => true,
      }

      if versioncmp($facts['os']['release']['full'], '20.04') >= 0 {
        package { 'systemd-timesyncd':
          ensure => 'latest',
          before => Service['systemd-timesyncd'],
        }
      }
      package::remove('chrony')

      profile::system::time::ntp::rtc { $ntp_client:
        service_name => systemd-timesyncd,
      }
    }
    default: {
      fail('Unsupport `ntp_client`')
    }
  }

  $_enable_chrony = $ntp_client == 'chrony'
  service { 'chronyd':
    ensure => ensure_service($_enable_chrony),
    enable => $_enable_chrony,
  }

  $_enable_timesyncd = $ntp_client == 'systemd-timesyncd'
  service { 'systemd-timesyncd':
    ensure => ensure_service($_enable_timesyncd),
    enable => $_enable_timesyncd,
  }

  if $_enable_chrony or $_enable_timesyncd {
    # service names differ on Debian/RHEL, we simply disable both
    service { ['ntp', 'ntpd']:
      ensure => 'stopped',
      enable => mask,
    }
  }
}
