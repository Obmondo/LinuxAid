class sentry::config (
  $admin_email       = $sentry::admin_email,
  $admin_password    = $sentry::admin_password,
  $custom_config     = $sentry::custom_conifg,
  $custom_settings   = $sentry::custom_settings,
  $db_host           = $sentry::db_host,
  $db_name           = $sentry::db_name,
  $db_password       = $sentry::db_password,
  $db_port           = $sentry::db_port,
  $db_user           = $sentry::db_user,
  $group             = $sentry::group,
  $ldap_base_ou      = $sentry::ldap_base_ou,
  $ldap_domain       = $sentry::ldap_domain,
  $ldap_group_base   = $sentry::ldap_group_base,
  $ldap_group_dn     = $sentry::ldap_group_dn,
  $ldap_host         = $sentry::ldap_host,
  $ldap_user         = $sentry::ldap_user,
  $ldap_password     = $sentry::ldap_password,
  $memcached_host    = $sentry::memcached_host,
  $memcached_port    = $sentry::memcached_port,
  $metrics_enable    = $sentry::metrics_enable,
  $metrics_backend   = $sentry::metrics_backend,
  $organization      = $sentry::organization,
  $path              = $sentry::path,
  $redis_host        = $sentry::redis_host,
  $redis_port        = $sentry::redis_port,
  $secret_key        = $sentry::secret_key,
  $smtp_host         = $sentry::smtp_host,
  $statsd_host       = $sentry::statsd_host,
  $statsd_port       = $sentry::statsd_port,
  $user              = $sentry::user,
) {
  assert_private()

  file { "${path}/sentry.conf.py":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('sentry/sentry.conf.py.erb'),
  }

  file { "${path}/config.yml":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('sentry/config.yml.erb'),
  }
}
