# MongoDB class
class profile::db::mongodb (
  Boolean                        $create_admin            = $role::db::mongodb::create_admin,
  Optional[String]               $admin_username          = $role::db::mongodb::create_admin::admin_username,
  Optional[Eit_types::Password]  $admin_password          = $role::db::mongodb::create_admin::admin_password,
  Array[String]                  $admin_roles             = $role::db::mongodb::create_admin::admin_roles,
  Boolean                        $admin_store_credentials = $role::db::mongodb::create_admin::admin_store_credentials,
  Boolean                        $ssl                     = $role::db::mongodb::ssl,
  Optional[Stdlib::Absolutepath] $ssl_ca                  = $role::db::mongodb::ssl::ca,
  Optional[Stdlib::Absolutepath] $ssl_key                 = $role::db::mongodb::ssl::key,
) {

  $_server_settings = {
    manage_pidfile  => false,
    ensure          => true,
    dbpath          => undef,
    # If we pass undef directly we just get the default from the module
    logpath         => false,
    # Since we run under systemd we'd rather not fork and instead output logs
    # on stdout/stderr.
    fork            => false,
    bind_ip         => ['127.0.0.1'],
    ipv6            => false,
    port            => 27017,
    journal         => true,
    nojournal       => false,   # this is a bit weird, but...
    smallfiles      => false,
    auth            => true,
    noauth          => false,
    verbose         => false,
    verbositylevel  => '',
    objcheck        => true,
    quota           => false,
    quotafiles      => undef,
    directoryperdb  => false,
    maxconns        => undef,
    nohttpinterface => false,
    noscripting     => false,
    notablescan     => false,
    noprealloc      => false,
    nssize          => 16,
    rest            => false,
    storage_engine  => 'wiredTiger',
    set_parameter   => undef,
    restart         => true,
    create_admin    => $create_admin,
    admin_username  => $admin_username,
    admin_password  => $admin_password,
    admin_roles     => $admin_roles,
    store_creds     => $admin_store_credentials,
    ssl             => $ssl,
    ssl_ca          => $ssl_ca,
    ssl_key         => $ssl_key,
  }

  # Need to force this due to https://tickets.puppetlabs.com/browse/MODULES-5274
  Package <| title == 'mongodb_server' |> {
    ensure => 'present',
  }

  Package <| title == 'mongodb_client' |> {
    ensure => 'present',
  }

  class {'::mongodb::globals':
    version             => '8.0',
    manage_package      => true,
    manage_package_repo => true,
  }

  class {'::mongodb::client':
    ensure => true,
  }

  class { '::mongodb::server':
    * => $_server_settings,
  }

  if $facts['os']['selinux']['enabled'] {
    selinux::fcontext { 'selinux-fcontext-mongodb-datadir':
      pathname            => $_dbpath, #lint:ignore:variable_scope # FIXME
      context             => 'mongod_var_lib_t',
      restorecond_recurse => true,
      require             => File[$_dbpath], #lint:ignore:variable_scope # FIXME
      before              => Class['::mongodb::server::service'],
    }
  }

  # Get the Ipv6 Host from the array
  $mongo_dest_ipv6 = $_server_settings['bind_ip'].filter |$host| {
    $host =~ Stdlib::IP::Address::V6
  }

  # Get the Ipv4 Host from the array
  $mongo_dest_ipv4 = $_server_settings['bind_ip'].filter |$host| {
    $host =~ Stdlib::IP::Address::V4
  }

  # Setup Firewall
  firewall_multi {
    default:
      ensure => present,
      proto  => 'tcp',
      dport  => $_server_settings['port'],
      jump   => 'accept',
      ;

    '000 allow mongodb ipv4':
      destination => $mongo_dest_ipv4,
      protocol    => 'iptables',
      ;

    '000 allow mongodb ipv6':
      destination => $mongo_dest_ipv6,
      protocol    => 'ip6tables',
      ;
  }

  $_mongodb_tools_package = regsubst($::mongodb::server::install::package_name, /-server/, '-tools')
  package::install($_mongodb_tools_package, {
    require => Class['::mongodb::repo'],
  })

  mongodb_user { 'obmondo-monitor':
    ensure        => present,
    database      => 'admin',
    password_hash => mongodb_password('obmondo-mon', stdlib::fqdn_rand_string(20)),
    roles         => ['clusterMonitor', 'readAnyDatabase'],
    require       => Class['mongodb::server'],
  }

}
