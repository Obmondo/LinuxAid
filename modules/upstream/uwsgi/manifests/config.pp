# == Class uwsgi::config
#
# This class is called from uwsgi for service config.
#
class uwsgi::config inherits uwsgi {

  file { $::uwsgi::config_directory:
    ensure => directory,
    owner  => $::uwsgi::user,
    group  => $::uwsgi::group,
  }

  file { $::uwsgi::plugins_directory:
    ensure => directory,
    owner  => $::uwsgi::user,
    group  => $::uwsgi::group,
  }

  file { $::uwsgi::config_file:
    ensure  => present,
    owner   => $::uwsgi::user,
    group   => $::uwsgi::group,
    mode    => '0644',
    content => template('uwsgi/uwsgi.ini.erb'),
    require => File[$::uwsgi::config_directory],
  }

  file { $::uwsgi::service_file:
    ensure  => $::uwsgi::service_file_ensure,
    owner   => $::uwsgi::user,
    group   => $::uwsgi::group,
    mode    => $::uwsgi::service_mode,
    content => template($::uwsgi::service_file_template),
  }

  file { $::uwsgi::app_directory:
    ensure  => directory,
    owner   => $::uwsgi::user,
    group   => $::uwsgi::group,
    recurse => true,
    purge   => $::uwsgi::purge,
    mode    => '0644',
    require => File[$::uwsgi::config_directory],
  }
}
