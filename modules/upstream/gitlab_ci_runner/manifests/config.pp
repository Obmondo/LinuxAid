# @summary Manages the configuration of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::config (
  $config_path       = $gitlab_ci_runner::config_path,
  $config_owner      = $gitlab_ci_runner::config_owner,
  $config_group      = $gitlab_ci_runner::config_group,
  $config_mode       = $gitlab_ci_runner::config_mode,
  $manage_config_dir = $gitlab_ci_runner::manage_config_dir,
  $config_dir_mode   = $gitlab_ci_runner::config_dir_mode,
  $concurrent        = $gitlab_ci_runner::concurrent,
  $log_level         = $gitlab_ci_runner::log_level,
  $log_format        = $gitlab_ci_runner::log_format,
  $check_interval    = $gitlab_ci_runner::check_interval,
  $shutdown_timeout  = $gitlab_ci_runner::shutdown_timeout,
  $sentry_dsn        = $gitlab_ci_runner::sentry_dsn,
  $session_server    = $gitlab_ci_runner::session_server,
  $listen_address    = $gitlab_ci_runner::listen_address,
  $package_name      = $gitlab_ci_runner::package_name,
) {
  assert_private()

  concat { $config_path:
    ensure         => present,
    owner          => $config_owner,
    group          => $config_group,
    mode           => $config_mode,
    ensure_newline => true,
  }

  $global_options = {
    concurrent       => $concurrent,
    log_level        => $log_level,
    log_format       => $log_format,
    check_interval   => $check_interval,
    shutdown_timeout => $shutdown_timeout,
    sentry_dsn       => $sentry_dsn,
    session_server   => $session_server,
    listen_address   => $listen_address,
  }.filter |$key, $val| { $val =~ NotUndef }

  concat::fragment { "${config_path} - header":
    target  => $config_path,
    order   => 0,
    content => '# MANAGED BY PUPPET',
  }

  concat::fragment { "${config_path} - global options":
    target  => $config_path,
    order   => 1,
    content => gitlab_ci_runner::to_toml($global_options),
  }

  if $manage_config_dir {
    $_config_dir = dirname($config_path)

    file { $_config_dir:
      ensure => 'directory',
      owner  => $config_owner,
      group  => $config_group,
      mode   => $config_dir_mode,
    }
  }
}
