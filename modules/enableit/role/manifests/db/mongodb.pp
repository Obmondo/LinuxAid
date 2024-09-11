# Mongodb Role
class role::db::mongodb (
  Variant[Pattern[/[0-9]+\.[0-9]+/]] $version            = undef,
  Boolean $use_upstream_repo                             = true,
  Array[Eit_types::IP] $listen_ips                       = ['127.0.0.1'],
  Boolean $use_ipv6                                      = false,
  Stdlib::Port $port                                  = 27017,
  Boolean $journal                                       = true,
  Boolean $smallfiles                                    = false,
  Boolean $remote_user_auth                              = true,
  Boolean $disable_auth                                  = false,
  Integer[0,4] $verbosity                                = 0,
  Boolean $object_check                                  = true,
  Boolean $http_interface                                = true,
  Hash[String,String] $extra_server_options              = {},
  Boolean $disable_scripting                             = false,
  Boolean $disable_tablescan                             = false,
  Boolean $disable_prealloc                              = false,
  Integer[1,default] $default_namespace_file_size        = 16,
  Boolean $restart_on_change                             = true,
  Boolean $create_admin                                  = false,
  Boolean $directory_per_db                              = false,
  Boolean $enable_rest_api                               = false,
  Boolean $ssl                                           = false,
  Optional[Stdlib::Absolutepath] $ssl_ca                 = undef,
  Optional[Stdlib::Absolutepath] $ssl_key                = undef,
  Variant[Integer[1,default], Boolean] $quota            = false,
  Optional[Stdlib::Absolutepath] $db_dir                 = undef,
  Optional[Enum['wiredTiger', 'mmapv1']] $storage_engine = 'wiredTiger',
  Optional[String] $admin_username                       = undef,
  Optional[Eit_types::Password] $admin_password          = undef,
  Array[String] $admin_roles                             = ['root'],
  Boolean $admin_store_credentials                       = true,
  Optional[Stdlib::Absolutepath] $log_file               = undef,
  Optional[Integer[1,default]] $max_connections          = undef,
  Eit_types::User $monitor_user                          = 'obmondo-mon',
  Eit_types::Password $monitor_password                  = undef,
  Boolean $backup                                        = false,
) inherits ::role::db {

  # FUTURE: When we support replication from the role, make sure to default to
  # the v1 protocol: https://jepsen.io/analyses/mongodb-3-4-0-rc3

  confine($remote_user_auth,
    $disable_auth,
    'Disabling authentication globally is not possible while requiring authentication for remote users')
  confine($ssl, !$ssl_key, 'Enabling `ssl` requires `ssl_key` to be set')
  confine(!$ssl, $ssl_ca, '`ssl_ca` should only be used when `ssl` is enabled')

  confine($create_admin,
    !($admin_username and $admin_password and $admin_roles),
    'If `create_admin` is enabled, `admin_username`, `admin_password` and `admin_roles` must be set.')

  confine(!$create_admin, $admin_store_credentials !~ Undef, '`create_admin` must be enabled if `admin_store_credentials` is set')

  # verbositylevel is a string of up to 5 repeated 'v's
  $_verbosity = join(range(1,$verbosity).each |$_| { 'v' }, '')

  # Since we run under systemd we'd rather not fork and instead output logs on
  # stdout/stderr.
  $_fork = !!$log_file

  # Always listen on localhost
  $_listen_ips = unique(concat($listen_ips, ['127.0.0.1']))

  class { '::profile::mongodb':
    monitor_user     => $monitor_user,
    monitor_password => $monitor_password,
    backup           => $backup,
    global_settings  => {
      version             => $version,
      manage_package      => true,
      manage_package_repo => $use_upstream_repo,
    },

    server_settings  => {
      ensure          => true,
      dbpath          => $db_dir,
      # If we pass undef directly we just get the default from the module
      logpath         => pick($log_file, false),
      fork            => $_fork,
      bind_ip         => $_listen_ips,
      ipv6            => $use_ipv6,
      port            => $port,
      journal         => $journal,
      nojournal       => !$journal,   # this is a bit weird, but...
      smallfiles      => $smallfiles,
      auth            => $remote_user_auth,
      noauth          => $disable_auth,
      verbose         => $verbosity > 0,
      verbositylevel  => lest($_verbosity) || { undef },
      objcheck        => $object_check,
      quota           => !!$quota,
      # Set to undef if quota is nit an Integer
      quotafiles      => if $quota =~ Integer { $quota },
      directoryperdb  => $directory_per_db,
      maxconns        => $max_connections,
      nohttpinterface => !$http_interface,
      noscripting     => $disable_scripting,
      notablescan     => $disable_tablescan,
      noprealloc      => $disable_prealloc,
      nssize          => $default_namespace_file_size,
      rest            => $enable_rest_api,
      storage_engine  => $storage_engine,
      set_parameter   => if size($extra_server_options) > 0 { $extra_server_options },
      restart         => $restart_on_change,
      create_admin    => $create_admin,
      admin_username  => $admin_username,
      admin_password  => $admin_password,
      admin_roles     => $admin_roles,
      store_creds     => $admin_store_credentials,
      ssl             => $ssl,
      ssl_ca          => $ssl_ca,
      ssl_key         => $ssl_key,
    },
  }
}
