# System Updates.
class common::system::updates (
  Boolean           $enable                 = true,
  Boolean           $snapshot               = true,
  Array             $blacklist              = [],
  Boolean           $remove_unused_packages = true,
  Boolean           $remove_unused_kernels  = true,
  Boolean           $reboot                 = false,
  Eit_types::Email  $mail_to                = 'ops@obmondo.com',
  Optional[Boolean] $noop_value             = false,
) {

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
  ]):
    ensure => 'absent',
  }

  common::services::systemd { 'yum-system-upgrade.service':
    ensure => 'absent',
  }

  # old bash script, so lets remove this
  file { '/usr/local/sbin/obmondo-system-update':
    ensure => absent,
  }

  package { 'obmondo-system-update':
    ensure => ensure_latest($enable),
  }

  file { '/etc/default/obmondo-update':
    ensure  => ensure_present($enable),
    content => anything_to_ini({
      'PUPPETCERT'    => $facts.dig('hostcert'),
      'PUPPETPRIVKEY' => $facts.dig('hostprivkey'),
      'HOSTNAME'      => $facts['networking']['hostname'],
    }),
    mode    => '0644',
    require => Package['obmondo-system-update'],
    noop    => $noop_value,
  }

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
    EnvironmentFile=-/etc/default/obmondo-update
    Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin:/opt/obmondo/bin"
    ExecStart=/opt/obmondo/bin/obmondo-system-update
    | EOT

  systemd::timer { 'obmondo-system-update.timer':
    ensure          => ensure_present($enable),
    timer_content   => $_timer,
    service_content => $_service,
    active          => $enable,
    enable          => $enable,
    require         => Package['obmondo-system-update'],
  }
}
