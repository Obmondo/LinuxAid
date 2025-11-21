# @summary Class for managing system updates
#
# @param manage Boolean determines if the system updates service is managed. Defaults to true.
#
# @param enable Boolean indicating whether automatic updates are enabled. Defaults to true.
#
# @param snapshot Boolean indicating whether snapshots should be taken before updates. Defaults to true.
#
# @param blacklist Array of package names to exclude from updates. Defaults to an empty array.
#
# @param remove_unused_packages Boolean indicating whether to remove unused packages. Defaults to true.
#
# @param remove_unused_kernels Boolean indicating whether to remove unused kernels. Defaults to true.
#
# @param reboot Boolean indicating whether to reboot after updates. Defaults to false.
#
# @param mail_to Email address to notify after updates. Defaults to 'ops@obmondo.com'.
#
# @param noop_value Optional Boolean to perform no-op runs for testing. Defaults to false.
#
class common::system::updates (
  Boolean               $manage                 = false,
  Boolean               $enable                 = false,
  Boolean               $snapshot               = true,
  Array                 $blacklist              = [],
  Boolean               $remove_unused_packages = true,
  Boolean               $remove_unused_kernels  = true,
  Boolean               $reboot                 = false,
  Eit_types::Email      $mail_to                = 'ops@obmondo.com',
  Eit_types::Noop_Value $noop_value             = undef,
) {
  if $manage {
    # NOTE: We will only install updates when purge is true, so that gives us some
    # confidence that we will not install updates from unwanted sources.
    $purge_settings = lookup('common::repo::purge', Boolean, undef, false)

    confine($enable, !$purge_settings, 'Automatic update is disabled, since all the repos are not managed by puppet, you can enable it via common::repo::purge: true') #lint:ignore:140chars

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
    ]): ensure => 'absent', }

    common::services::systemd { 'yum-system-upgrade.service':
      ensure => 'absent',
    }

    package { 'obmondo-system-update':
      ensure => absent,
      noop   => $noop_value,
    }

    file { '/etc/default/obmondo-update':
      ensure => absent,
      noop   => $noop_value,
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
        ensure          => ensure_present($enable),
        timer_content   => $_timer,
        service_content => $_service,
        active          => $enable,
        enable          => $enable,
      }
    }
  }
}
