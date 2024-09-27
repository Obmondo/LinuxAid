# Azure discovery agent
class profile::software::oms_agent (
  Boolean                           $enable                 = $common::software::oms_agent::enable,
  Boolean                           $manage                 = $common::software::oms_agent::manage,
  Optional[Eit_types::SimpleString] $version                = $common::software::oms_agent::version,
  Optional[Boolean]                 $noop_value             = $common::software::oms_agent::noop_value,
  Optional[String]                  $workspace_id           = $common::software::oms_agent::workspace_id,
  Optional[String]                  $workspace_key          = $common::software::oms_agent::workspace_key,
  Optional[String]                  $checksum               = $common::software::oms_agent::checksum,
) {

  $service_file = sprintf('/lib/systemd/system/omsagent-%s.service', $workspace_id)

  $_users = [
    'nxautomation',
    'omsagent',
  ]
  $_groups = [
    'omiusers',
    'omsagent',
    'nxautomation',
  ]

  File {
    noop   => $noop_value,
    ensure => ensure_file($enable),
    before => if $enable { User[$_users] },
  }

  # we don't want to remove this dir even if omsagent is disabled as it's also
  # used for other Microsoft services
  if $enable {
    file { '/var/opt/microsoft':
      ensure => 'directory',
    }
  }

  file { [
    '/var/opt/microsoft/omsagent',
    '/var/opt/microsoft/nxautomation',
  ]:
    ensure  => ensure_dir($enable),
    recurse => true,
    force   => unless $enable { true },
  }

  User {
    ensure             => ensure_present($enable),
    password           => '!!',
    password_max_age   => -1,
    password_min_age   => -1,
    password_warn_days => -1,
    shell              => '/bin/bash',
    require            => if $enable { Group[$_groups] },
    before             => unless $enable { Group[$_groups] },
    noop               => $noop_value,
  }

  group { $_groups:
    ensure => ensure_present($enable),
    system => true,
    noop   => $noop_value,
  }

  user { 'omsagent':
    ensure  => ensure_present($enable),
    comment => 'OMS agent',
    home    => '/var/opt/microsoft/omsagent/run',
    groups  => ['omiusers'],
  }

  user { 'nxautomation':
    ensure  => ensure_present($enable),
    comment => 'nxOMSAutomation',
    groups  => ['omiusers', 'omsagent', 'nxautomation'],
    home    => '/var/opt/microsoft/nxautomation/run',
  }

  profile::system::sudoers::conf { 'omsagent':
    ensure        => ensure_present($enable),
    # this is the default location, and it seems like omsagent will randomly
    # drop the file in here, so let's just keep it in this location
    filename      => 'omsagent',
    sudoers_d_dir => '/etc/sudoers.d',
    source        => 'puppet:///modules/profile/software/omsagent.sudo',
    noop_value    => $noop_value,
  }

  file { '/etc/omsagent-onboard.conf':
    ensure  => ensure_file($enable),
    content => "WORKSPACE_ID=${workspace_id}\nSHARED_KEY=${workspace_key}\n"
  }

  $service = sprintf('omsagent-%s', $workspace_id)

  package { ['omsagent','omi', 'scx']:
    ensure  => ensure_latest($enable),
    noop    => $noop_value,
    require => if $enable { File['/etc/omsagent-onboard.conf'] },
  }

  service { $service:
    ensure  => $enable,
    noop    => $noop_value,
    enable  => $enable,
    require => if $enable { Package['omsagent', 'omi', 'scx'] },
  }

  file { '/etc/opt/microsoft/omsagent/conf/omsagent.d/container.conf':
    ensure => 'absent',
    noop   => $noop_value,
    notify => Service[$service]
  }

  # File contains no entries but it's unique per host due to an UUID written
  # in there. We manage it so it doesn't get purged.
  file { '/etc/rsyslog.d/95-omsagent.conf':
    ensure => ensure_file($enable),
    owner  => 'omsagent',
    group  => 'omiusers',
  }

  profile::cron::job { 'OMSConsistencyInvoker':
    enable     => $enable,
    minute     => cron_minutes_interval(15),
    user       => 'omsagent',
    command    => '/opt/omi/bin/OMSConsistencyInvoker >/dev/null 2>&1',
    require    => if $enable {
      [
        User['omsagent'],
        Service[$service],
      ]
    },
    noop_value => $noop_value,
  }

  if $manage and $enable {
    # Remove all the logrotate snippets. We need to use tidy to use the glob, as
    # the omsagent file has a random UUID in the name
    tidy { 'ms logrotate files':
      path    => '/etc/logrotate.d',
      matches => [
        'omi',
        'omsagent-*',
        'omsconfig',
        'scxagent',
      ],
      recurse => 1,
      noop    => $noop_value,
    }

    # Remove all the logrotate cron jobs.
    tidy { 'ms logrotate cron job files':
      path    => '/etc/cron.d',
      matches => [
        'omilogrotate',
        'omsagent',
        'scxagent',
        'OMSConsistencyInvoker',
      ],
      recurse => 1,
      noop    => $noop_value,
    }

    # Remove systemd unit
    tidy { 'ms omsagent service with uuid':
      path    => '/usr/lib/systemd/system',
      matches => [
        'omsagent-*.service'
      ],
      recurse => 1,
      noop    => $noop_value,
      notify  => if $::facts['service_provider'] == 'systemd' { Exec['daemon-reload'] },
      require => Service[$service],
      before  => User[$_users],
    }
  }

  logrotate::rule { 'ms_agents':
    ensure        => ensure_present($enable),
    path          => [
      '/var/opt/microsoft/omsagent/log/*.log',
      '/var/opt/microsoft/omsconfig/*.log',
      # we might want to move these lines to an Azure WAAgent profile at some
      # point
      '/var/log/azure/*/*.log',
    ],
    rotate_every  => 'daily',
    rotate        => 30,
    missingok     => true,
    ifempty       => false,
    compress      => true,
    delaycompress => false,
    dateext       => true,
    # this might solve the issue of OMS leaving deleted files, see
    # https://support.obmondo.com/issues/4151
    copytruncate  => true,
  }

}
