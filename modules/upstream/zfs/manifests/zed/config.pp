# @!visibility private
class zfs::zed::config {

  $conf_dir                 = $zfs::zed::conf_dir
  $debug_log                = $zfs::zed::debug_log
  $email_addrs              = $zfs::zed::email_addrs
  $email_opts               = $zfs::zed::email_opts
  $email_prog               = $zfs::zed::email_prog
  $lock_dir                 = $zfs::zed::lock_dir
  $notify_interval_secs     = $zfs::zed::notify_interval_secs
  $notify_verbose           = $zfs::zed::notify_verbose
  $pushbullet_access_token  = $zfs::zed::pushbullet_access_token
  $pushbullet_channel_tag   = $zfs::zed::pushbullet_channel_tag
  $run_dir                  = $zfs::zed::run_dir
  $service_name             = $zfs::zed::service_name
  $spare_on_checksum_errors = $zfs::zed::spare_on_checksum_errors
  $spare_on_io_errors       = $zfs::zed::spare_on_io_errors
  $syslog_priority          = $zfs::zed::syslog_priority
  $use_enclosure_leds       = $zfs::zed::use_enclosure_leds
  $syslog_tag               = $zfs::zed::syslog_tag
  $zedlet_dir               = $zfs::zed::zedlet_dir

  file { $conf_dir:
    ensure       => directory,
    owner        => 0,
    group        => 0,
    mode         => '0644',
    force        => true,
    purge        => true,
    recurse      => true,
    recurselimit => 1,
  }

  case $facts['os']['family'] {
    'RedHat': {
      # Prevent it from being purged away
      file { "${conf_dir}/zed-functions.sh":
        ensure => file,
        owner  => 0,
        group  => 0,
        mode   => '0644',
      }
    }
    'Debian': {
      case $facts['os']['name'] {
        'Ubuntu': {
          case $facts['os']['release']['full'] {
            '16.04': {
              # 16.04 native package has this located in installed zedlets
              # directory so symlink it in and treat it like a regular zedlet
              zfs::zed::zedlet { 'zed-functions.sh': }
            }
            default: {
              # Prevent it from being purged away
              file { "${conf_dir}/zed-functions.sh":
                ensure => file,
                owner  => 0,
                group  => 0,
                mode   => '0644',
              }
            }
          }
        }
        default: {
          # Prevent it from being purged away
          file { "${conf_dir}/zed-functions.sh":
            ensure => file,
            owner  => 0,
            group  => 0,
            mode   => '0644',
          }

          file { "/etc/systemd/system/${service_name}.service.d":
            ensure => directory,
            owner  => 0,
            group  => 0,
            mode   => '0644',
          }

          ensure_resource('exec', 'systemctl daemon-reload', {
            refreshonly => true,
            path        => $facts['path'],
          })

          $content = @(EOS/L)
            [Service]
            ExecStart=
            ExecStart=/usr/sbin/zed -F
            | EOS

          # Current Debian package ships a broken zed service unit file
          file { "/etc/systemd/system/${service_name}.service.d/override.conf":
            ensure  => file,
            owner   => 0,
            group   => 0,
            mode    => '0644',
            content => $content,
            notify  => Exec['systemctl daemon-reload'],
          }
        }
      }
    }
    default: {
      # noop
    }
  }

  file { "${conf_dir}/zed.rc":
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template("${module_name}/zed.rc.erb"),
  }

  $zfs::zed::zedlets.each |$resource,$attributes| {
    zfs::zed::zedlet { $resource:
      * => $attributes,
    }
  }
}
