# @summary Class for managing system updates
#
# @param manage Boolean - If true, purges unattended-upgrades (and yum-cron on RedHat), so only
# linuxaid-cli updates the system. Purging also removes /etc/apt/apt.conf.d/20auto-upgrades, which
# makes apt's own daily job refresh the package lists. Defaults to false.
#
# @param enable Boolean - If true, together with manage, sets up the obmondo-system-update timer
# (a cron job on sysvinit) that runs linuxaid-cli system-update. If false, the timer is never set
# up or touched. Defaults to false.
#
# @param noop_value Optional Boolean to perform no-op runs for testing. Defaults to false.
#
# @groups general manage, enable
#
# @groups noop noop_value
#
class common::system::updates (
  Boolean               $manage                 = false,
  Boolean               $enable                 = false,
  Eit_types::Noop_Value $noop_value             = undef,
) {
  if $manage {
    $repo_managed = lookup('common::system::repo::manage', Boolean, undef, true)
    $purge_settings = lookup('common::system::repo::purge', Boolean, undef, false)

    if $repo_managed {
      confine($enable, !$purge_settings, 'Automatic update is disabled, since all the repos are not managed by puppet, you can enable it via common::system::repo::purge: true') #lint:ignore:140chars
    }

    $_os_family = $facts['os']['family']

    File {
      noop => $noop_value,
    }
    Package {
      noop => $noop_value,
    }
    Service {
      noop => $noop_value,
    }

    package { delete_undef_values([
      'unattended-upgrades',
      if $_os_family == 'RedHat' {
        'yum-cron'
      },
    ]): ensure => 'purged', }

    # Ensure the service is stopped and disabled on RedHat systems
    if $_os_family == 'RedHat' {
      service { 'yum-system-upgrade.service':
        ensure => 'stopped',
        enable => false,
      }
    }

    package { 'obmondo-system-update':
      ensure => absent,
      noop   => $noop_value,
    }

    file { '/etc/default/obmondo-update':
      ensure => absent,
      noop   => $noop_value,
    }

    # Set up the obmondo-system-update timer only with enable: true. With enable: false an
    # existing timer is left alone, e.g. on KubeAid nodes, where kubeaid-agent runs the
    # system updates.
    if $enable {
      if $facts['init_system'] == 'sysvinit' {
        # NOTE: sysvinit systems (like turrisos) get a cron job instead of a timer.
        cron { 'obmondo-system-update':
          ensure  => present,
          command => '/opt/obmondo/bin/linuxaid-cli system-update',
          user    => 'root',
          minute  => fqdn_rand(59, $facts['networking']['hostname']),
          hour    => '*',
          noop    => $noop_value,
        }
      }

      if $facts['init_system'] == 'systemd' {
        # Change the upgrade service timer timing.
        $_minutes = fqdn_rand(30, $facts['networking']['hostname'])

        $_timer = @("EOT"/$n)
          # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
          [Unit]
          Description=Obmondo System Update Timer
          Requires=obmondo-system-update.service
          [Timer]
          OnCalendar=*-*-* *:0/30:00
          RandomizedDelaySec=${_minutes}m
          | EOT

        $_service = @(EOT)
          # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
          [Unit]
          Description=Obmondo System Update Service
          Wants=obmondo-system-update.timer
          [Service]
          Type=oneshot
          EnvironmentFile=-/etc/default/linuxaid-cli
          Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin:/opt/obmondo/bin"
          ExecStart=/opt/obmondo/bin/linuxaid-cli system-update
          | EOT

        systemd::timer { 'obmondo-system-update.timer':
          ensure          => present,
          timer_content   => $_timer,
          service_content => $_service,
          active          => true,
          enable          => true,
        }
      }
    }
  }
}
