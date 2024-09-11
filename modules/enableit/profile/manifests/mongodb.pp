# MongoDB class
class profile::mongodb (
  Hash                $global_settings,
  Hash                $server_settings,
  Eit_types::User     $monitor_user,
  Eit_types::Password $monitor_password,
  Hash                $server_defaults = {
    manage_pidfile => false,
  },
  Boolean             $backup           = false,
) {

  # Backup
  if $backup {
    contain common::backup::db::mongodb
  }

  # Bind Ip
  $_bind = $server_settings['bind_ip']

  $_server_settings = $server_defaults + $server_settings

  # Need to force this due to https://tickets.puppetlabs.com/browse/MODULES-5274
  Package <| title == 'mongodb_server' |> {
    ensure => 'present',
  }

  Package <| title == 'mongodb_client' |> {
    ensure => 'present',
  }

  class {'::mongodb::globals':
    * => $global_settings,
  }

  class {'::mongodb::client':
    ensure => true,
  }

  class { '::mongodb::server':
    * => $_server_settings,
  }

  if $facts['selinux'] {
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
    password_hash => mongodb_password($monitor_user, $monitor_password),
    roles         => ['clusterMonitor', 'readAnyDatabase'],
    require       => Class['mongodb::server'],
  }

}
