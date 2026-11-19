# @summary Class for managing system updates
#
# @param manage Boolean determines if the system updates service is managed. Defaults to true.
#
# @param enable Boolean indicating whether automatic updates are enabled. Defaults to true.
#
# @param snapshot Boolean indicating whether snapshots should be taken before updates. Defaults to true.
#
# @param noop_value Optional Boolean to perform no-op runs for testing. Defaults to false.
#
# @groups general manage, enable, snapshot
#
# @groups noop noop_value
#
class common::system::updates (
  Boolean               $manage                 = false,
  Boolean               $enable                 = false,
  Boolean               $snapshot               = true,
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
    ]): ensure => 'absent', }

    # Disable APT periodic package list updates and unattended upgrades, system
    # updates are handled by linuxaid-cli (obmondo-system-update) instead.
    # A plain file rather than apt::conf: apt::conf reads $apt::config_files, so it
    # needs Class['apt'], which role::kubeaid never declares (with strict variables
    # the whole catalog fails), and including apt here would clash with the
    # resource-style declaration in eit_repos.
    if $_os_family == 'Debian' {
      file { '/etc/apt/apt.conf.d/20auto-upgrades':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => @(EOT),
          # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
          APT::Periodic::Update-Package-Lists "0";
          APT::Periodic::Unattended-Upgrade "0";
          | EOT
      }
    }

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

    if $facts['init_system'] == 'sysvinit' {
      cron { 'obmondo-system-update':
        # NOTE: We're enabling the system update cron for sysvinit systems (like turrisos)
        # when $enable is true.
        ensure  => ensure_present($enable),
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
        ensure          => ensure_present($enable),
        timer_content   => $_timer,
        service_content => $_service,
        active          => $enable,
        enable          => $enable,
      }
    }
  }
}
