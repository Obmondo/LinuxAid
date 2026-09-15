# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc::config::profiles
class thinlinc::profiles (
  String        $default    = $::thinlinc::profile_default,
  Array[String] $order      = $::thinlinc::profile_order,
  Boolean       $show_intro = $::thinlinc::profile_show_intro,
  Boolean       $install    = $::thinlinc::profile_install,
) inherits ::thinlinc {

  file { "${thinlinc::install_dir}/etc/conf.d/profiles.hconf":
    ensure  => 'file',
    content => epp('thinlinc/conf.d/profiles.hconf.epp'),
  }

  # ThinLinc 4.21 logs sessions to the system journal instead of writing an
  # xinit.log per session, so there is nothing left to copy out at logout.
  # Retention now comes from journald - see
  # common::system::systemd::journald_settings.
  #
  # The directory is left in place: it still holds the logs collected while
  # this ran, and they are worth keeping until they age out.
  file { "${thinlinc::install_dir}/etc/xlogout.d/tl-log-rotation.sh":
    ensure => 'absent',
  }

  file { "${thinlinc::install_dir}/libexec/tl-log-rotation.sh":
    ensure => 'absent',
  }

  logrotate::rule { 'thinlinc-sessions':
    ensure => 'absent',
  }

}
