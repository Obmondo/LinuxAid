# Sentry Monitoring
class profile::sentry {
  include ::sentry
  include ::profile::db::pgsql::client

  Class['::profile::db::pgsql::client'] -> Class['::sentry']
}
