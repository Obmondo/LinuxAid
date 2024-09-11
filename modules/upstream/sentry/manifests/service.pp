# == Class: sentry::service
#
# This class is meant to be called from sentry.
# It ensures the background services are running via systemd
#
# === Parameters
#
# user: UNIX user to run Sentry services
# group: UNIX group to run Sentry services
# path: path to Sentry installation / virtualenv
#
# === Authors
#
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds
#
class sentry::service (
  $user = $sentry::user,
  $group = $sentry::group,
  $path = $sentry::path,
) {

  exec { 'enable-sentry-services':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    path        => '/bin:/sbin',
  }

  # Sentry Celery Worker
  file { '/etc/systemd/system/sentry-worker.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-worker.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }

  service { 'sentry-worker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [ File['/etc/systemd/system/sentry-worker.service'],
                    User[$user],
                  ],
  }

  # if the Sentry config changes, do a full restart of the Sentry Celery workers
  exec { 'restart-sentry-worker':
    command     => '/usr/bin/systemctl stop sentry-worker; /usr/bin/systemctl start sentry-worker',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Class['::sentry::config'],
  }

  # Sentry Celery Beat
  file { '/etc/systemd/system/sentry-beat.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-beat.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }

  service { 'sentry-beat':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [ File['/etc/systemd/system/sentry-beat.service'],
                    User[$user],
                  ],
  }

  # if the Sentry config changes, do a full restart of the Sentry beat worker
  exec { 'restart-sentry-beat':
    command     => '/usr/bin/systemctl stop sentry-beat; /usr/bin/systemctl start sentry-beat',
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Class['::sentry::config'],
  }

  # Setup log rotation
  logrotate::rule { 'sentry-worker':
    ensure       => present,
    path         => '/var/log/sentry/sentry-worker.log',
    create       => true,
    compress     => true,
    missingok    => true,
    rotate       => 14,
    ifempty      => false,
    create_mode  => '0644',
    create_owner => $user,
    create_group => $group,
  }

  logrotate::rule { 'sentry-beat':
    ensure       => present,
    path         => '/var/log/sentry/sentry-beat.log',
    create       => true,
    compress     => true,
    missingok    => true,
    rotate       => 14,
    ifempty      => false,
    create_mode  => '0644',
    create_owner => $user,
    create_group => $group,
  }

}
