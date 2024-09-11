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

  # Create a directory where we can copy the logs and give the required
  # permissions so that user can copy the files here
  file { '/var/log/thinlinc/sessions':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    require => File['/var/log/thinlinc'],
  }

  # A shell script which copies to log to the /var/log/thinlinc folder
  file { "${thinlinc::install_dir}/libexec/tl-log-rotation.sh":
    ensure  => present,
    source  => 'puppet:///modules/thinlinc/tl-log-rotation.sh',
    mode    => '0755',
    require => File['/var/log/thinlinc/sessions'],
  }

  # Create a symlink
  file { "${thinlinc::install_dir}/etc/xlogout.d/tl-log-rotation.sh":
    ensure => link,
    target => "${thinlinc::install_dir}/libexec/tl-log-rotation.sh",
  }

  # Logroate rule so that we don't keep the logs for more than a week
  logrotate::rule { 'thinlinc-sessions':
    ensure        => 'present',
    path          => '/var/log/thinlinc/sessions/*/*.log',
    rotate_every  => 'daily',
    rotate        => 30,
    compress      => true,
    create        => false,
    delaycompress => true,
    missingok     => true,
  }

}
