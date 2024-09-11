$active_host  = 'host1'
$passive_host = 'host2'
$active_ip    = '10.0.0.2'
$passive_ip   = '10.0.0.3'

node 'active' {
  # create logical volume for drbd
  logical_volume { 'drbd-openstack':
    ensure       => present,
    # grab from this existing volume
    volume_group => 'nova-volumes',
    size         => '1G',
  }

  include ::drbd

  drbd::resource { 'drbd':
    host1         => $active_host,
    host2         => $passive_host,
    ip1           => $active_ip,
    ip2           => $passive_ip,
    disk          => '/dev/mapper/nova--volumes-drbd--openstack',
    port          => '7789',
    device        => '/dev/drbd0',
    manage        => true,
    verify_alg    => 'sha1',
    ha_primary    => true,
    initial_setup => true,
    require       => Logical_volume['drbd-openstack'],
  }
}

node 'passive' {
  # create logical volume for drbd
  logical_volume { 'drbd-openstack':
    ensure       => present,
    # grab from this existing volume
    volume_group => 'nova-volumes',
    size         => '1G',
  }

  include ::drbd

  drbd::resource { 'drbd':
    host1         => $active_host,
    host2         => $passive_host,
    ip1           => $active_ip,
    ip2           => $passive_ip,
    disk          => '/dev/mapper/nova--volumes-drbd--openstack',
    port          => '7789',
    device        => '/dev/drbd0',
    manage        => true,
    verify_alg    => 'sha1',
    ha_primary    => false,
    initial_setup => false,
    require       => Logical_volume['drbd-openstack'],
  }
}
