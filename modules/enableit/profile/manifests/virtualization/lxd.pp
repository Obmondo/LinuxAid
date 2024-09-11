# LXD profile
class profile::virtualization::lxd (
  Eit_types::IP $network                               = '10.0.3.0',
  String $lxd_bridge                                   = 'lxdbr0',
  Hash $instances                                      = {},
  Array[Eit_types::SimpleString] $requires_filesystems = [],
) {

  $_requires_filesystems = $requires_filesystems.map |$fs| {
    Common::Device::Filesystem[$fs]
  }

  if $facts['os']['release']['full'] == '18.04' {
    $services = [ 'lxd', 'lxd-containers' ]
  } else {
    $services = [ 'lxd', 'lxd-bridge', 'lxd-containers' ]
  }

  $services.each | $servicename | {
    Resource[Service] { $servicename :
      ensure  => running,
      enable  => true,
      require => [Package['lxd']] + $_requires_filesystems,
    }
  }

  class { 'lxd':
    network              => $network,
    lxd_bridge           => $lxd_bridge,
    manage_firewall      => true,
    manage_logrotate     => true,
    requires_filesystems => $requires_filesystems,
  }

  $instances.each |$lxc_name, $conf| {
    $_lxc_conf = $conf.filter |$k, $_| {
      !($k in ['firewall', 'ip'])
    }

    lxc { $lxc_name:
      *       => $_lxc_conf,
      require => Class['lxd'],
    }

    unless $facts['os']['release']['full'] == '18.04' {
      ini_setting { "set dnsmasq static ip for ${lxc_name}":
        ensure            => present,
        path              => "/etc/lxd/dnsmasq.conf.d/${lxc_name}.conf",
        setting           => 'dhcp-host',
        value             => "${lxc_name},${conf['ip']}",
        key_val_separator => '=',
        notify            => Service['lxd-bridge'],
      }
    }

    pick($conf['firewall'], {}).map |$rule, $spec| {
      $_weight = pick($spec['weight'], 100)
      $_name = "${_weight} lxd - ${rule} ${spec['protocols']}"
      firewall_multi { "${_name} - forward to lxc ${name}":
        table  => 'nat',
        proto  => $spec['protocols'],
        dport  => $spec['ports'],
        chain  => 'PREROUTING',
        jump   => 'DNAT',
        source => $spec['source'],
        todest => $conf['ip'],
      }
    }
  }
}
