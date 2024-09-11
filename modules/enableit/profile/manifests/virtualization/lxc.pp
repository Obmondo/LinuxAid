# LXC Profile, this is too static
class profile::virtualization::lxc (
  String              $bridge,
  Eit_types::IPv4CIDR $network,
  Boolean             $__blendable,
) inherits profile {
  # Inherited because we don't want to server lxc profile, only lxd is what we want

  class { '::lxc' :
    network => $network,
    bridge  => $bridge,
  }

  # FIXME: TODO: Disabling it, since this needs a bit of work, or check lxd module
  #file { '/etc/default/lxc' :
  #  ensure => file,
  #  source => 'puppet:///modules/profile/enableit/beaker/lxc',
  #  mode   => '0644',
  #}

  #file { '/etc/dnsmasq.d/lxc' :
  #  ensure => file,
  #  source => 'puppet:///modules/profile/enableit/beaker/dnsmasq.lxc',
  #  mode   => '0644',
  #}

  service { 'lxc-net' :
    ensure  => running,
    require => Package['lxc'],
  }
}
