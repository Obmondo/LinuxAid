
# @summary Class for managing the MongoDB role
#
# @param version The version of MongoDB to install. Defaults to 8.0
#
# @param use_upstream_repo Whether to use the upstream repository. Defaults to true.
#
# @param listen_ips The IP addresses on which MongoDB will listen. Defaults to ['127.0.0.1'].
#
# @param use_ipv6 Whether to enable IPv6. Defaults to false.
#
# @param port The port on which MongoDB will listen. Defaults to 27017.
#
# @param journal Whether to enable journaling. Defaults to true.
#
# @param smallfiles Whether to use small files for the database. Defaults to false.
#
# @param remote_user_auth Whether to enable remote user authentication. Defaults to true.
#
# @param disable_auth Whether to disable authentication. Defaults to false.
#
# @param verbosity The verbosity level of logs. Defaults to 0.
#
# @param object_check Whether to perform object checks. Defaults to true.
#
# @param http_interface Whether to enable the HTTP interface. Defaults to true.
#
# @param extra_server_options Additional server options for MongoDB. Defaults to {}.
#
# @param disable_scripting Whether to disable scripting. Defaults to false.
#
# @param disable_tablescan Whether to disable table scans. Defaults to false.
#
# @param disable_prealloc Whether to disable preallocation of files. Defaults to false.
#
# @param default_namespace_file_size The default namespace file size in MB. Defaults to 16.
#
# @param restart_on_change Whether to restart MongoDB on configuration change. Defaults to true.
#
# @param create_admin Whether to create an admin user. Defaults to false.
#
# @param directory_per_db Whether to use a separate directory for each database. Defaults to false.
#
# @param enable_rest_api Whether to enable the REST API. Defaults to false.
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @param ssl_ca The SSL CA certificate path. Defaults to undef.
#
# @param ssl_key The SSL key path. Defaults to undef.
#
# @param quota The quota for connections. Defaults to false.
#
# @param db_dir The directory for the database files. Defaults to undef.
#
# @param storage_engine The storage engine to use. Defaults to 'wiredTiger'.
#
# @param admin_username The username for the admin user. Defaults to undef.
#
# @param admin_password The password for the admin user. Defaults to undef.
#
# @param admin_roles The roles for the admin user. Defaults to ['root'].
#
# @param admin_store_credentials Whether to store credentials for the admin user. Defaults to false.
#
# @param log_file The log file path. Defaults to undef.
#
# @param max_connections The maximum number of connections. Defaults to undef.
#
# @param monitor_user The username for the monitoring user. Defaults to 'obmondo-mon'.
#
# @param backup Whether to enable backups. Defaults to false.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups connection listen_ips, port, use_ipv6, max_connections
#
# @groups security remote_user_auth, disable_auth, ssl, ssl_ca, ssl_key, encrypt_params
#
# @groups storage journal, smallfiles, db_dir, storage_engine, directory_per_db
#
# @groups admin create_admin, admin_username, admin_password, admin_roles, admin_store_credentials
#
# @groups interface http_interface, enable_rest_api, monitor_user
#
# @groups logging verbosity, log_file, object_check
#
# @groups miscellaneous version, use_upstream_repo, extra_server_options, disable_scripting, disable_tablescan, disable_prealloc, default_namespace_file_size, restart_on_change, quota, backup
#
# @encrypt_params admin_password
#
class role::db::mongodb (
  Variant[Pattern[/[0-9]+\.[0-9]+/]] $version            = '8.0',
  Boolean $use_upstream_repo                             = true,
  Array[Eit_types::IP] $listen_ips                       = ['127.0.0.1'],
  Boolean $use_ipv6                                      = false,
  Stdlib::Port $port                                     = 27017,
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
  Boolean $admin_store_credentials                       = false,
  Optional[Stdlib::Absolutepath] $log_file               = undef,
  Optional[Integer[1,default]] $max_connections          = undef,
  Eit_types::User $monitor_user                          = 'obmondo-mon',
  Boolean $backup                                        = false,
  Eit_types::Encrypt::Params $encrypt_params             = [
    'admin_password',
  ],
) inherits ::role::db {

  # FUTURE: When we support replication from the role, make sure to default to
  # the v1 protocol: https://jepsen.io/analyses/mongodb-3-4-0-rc3
  confine($remote_user_auth,    $disable_auth,    'Disabling authentication globally is not possible while requiring authentication for remote users') #lint:ignore:140chars
  confine($ssl, !$ssl_key, 'Enabling `ssl` requires `ssl_key` to be set')
  confine(!$ssl, $ssl_ca, '`ssl_ca` should only be used when `ssl` is enabled')
  confine($create_admin,    !($admin_username and $admin_password and $admin_roles),    'If `create_admin` is enabled, `admin_username`, `admin_password` and `admin_roles` must be set.') #lint:ignore:140chars
  confine(!$create_admin, $admin_store_credentials !~ Undef, '`create_admin` must be enabled if `admin_store_credentials` is set')

  # verbositylevel is a string of up to 5 repeated 'v's
  $_verbosity = join(range(1,$verbosity).each |$_| { 'v' }, '')

  # Since we run under systemd we'd rather not fork and instead output logs on
  # stdout/stderr.
  $_fork = !!$log_file

  # Always listen on localhost
  $_listen_ips = unique(concat($listen_ips, ['127.0.0.1']))

  $monitor_password = stdlib::fqdn_rand_string(20)

  class { '::profile::db::mongodb':
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
      # Set to undef if quota is not an Integer
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
