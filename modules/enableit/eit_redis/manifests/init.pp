# EnableIT custom redis module
class eit_redis (
  Boolean $daemon                                        = false,
  Stdlib::Absolutepath $pidfile                          = '/var/run/redis/redis-server.pid',
  Stdlib::Port $default_port                          = 6379,
  Array[Variant[Eit_types::IP, Eit_types::IPPort]] $bind = ['127.0.0.1'],
  Integer[0, default] $timeout                           = 0,
  Integer[0, default] $tcpkeepalive                      = 0,
  Enum['debug', 'notice', 'warning', 'error'] $log_level = 'notice',
  Variant[Undef, Stdlib::Absolutepath] $logfile          = undef,
  Integer[0,default] $databases                          = 16,
  String $dbfilename                                     = 'dump.rdb',
  Stdlib::Absolutepath $dir                              = '/var/lib/redis',
  Boolean $manage_firewall                               = true,
  Enum[
    'eit_redis/redis.conf.erb',
    'eit_redis/logstash_redis.conf.erb'
  ] $config_template                                     = 'eit_redis/redis.conf.erb',
) {

  confine(!($facts['os']['family'] in ['Debian', 'RedHat']), 'Platform not supported')
  confine(!$logfile and $daemon, 'Not running as daemon and sending logs to stdout will cause logs to be redirected to /dev/null')

  # FIXME: check that IPPorts in $bind all have the same port; Redis supports
  # binding to multiple interfaces, but the port has to be the same, apparently.

  $conf_file = $facts['os']['family'] ? {
    'Debian' => '/etc/redis/redis.conf',
    'RedHat' => '/etc/redis.conf',
  }

  # Redis needs to be able to overcommit memory to work properly
  sysctl::configuration {
    'vm.overcommit_memory':
      value  => '1',
      ;

    'net.core.somaxconn':
      value => '65535',
      ;
    # Because of a bug in the sysctl module (unreported) we can't use the before
    # metaparameter as Puppet tries to redefine it.
  }

  package::install('redis', {
    before => [
      File[$conf_file],
      File[$dir],
    ],
  })

  file { $conf_file:
    ensure  => present,
    content => template($config_template),
    notify  => Service['redis'],
  }

  file { $dir:
    ensure => directory,
    owner  => redis,
    group  => redis,
    mode   => '0750',
  }

  if lookup('common::system::selinux::enable', Boolean, undef, false) {
    selinux::fcontext { 'selinux-fcontext-redis-datadir':
      pathname            => $dir,
      context             => 'redis_var_lib_t',
      restorecond_recurse => true,
      require             => File[$dir],
    }
  }

  service { 'redis':
    ensure  => running,
    enable  => true,
    require => [
      Sysctl::Configuration[
        'vm.overcommit_memory',
        'net.core.somaxconn',
      ],
      File[$conf_file],
    ],
  }

  $_ensure = if $manage_firewall { 'present' } else { 'absent' }

  # Remove localhost IPs; don't need to open the firewall for those
  $_ips = difference($bind, ['127.0.0.1', '::1'])

  $_ips.map |$ip| {
    # FIXME: provide a function split_addressport that takes a default port
    firewall { "${default_port} - redis accept ${ip}":
      ensure      => $_ensure,
      dport       => $default_port,
      proto       => tcp,
      jump        => accept,
      destination => $ip,
    }
  }
}
