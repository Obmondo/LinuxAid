# Logrotate
class lxd::logrotate {

  include ::logrotate

  logrotate::rule { 'lxd' :
    path          => '/var/log/lxd/lxd.log',
    rotate        => 90,
    missingok     => true,
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0600',
    rotate_every  => 'day',
  }

  logrotate::rule { 'lxd-lxc' :
    path          => '/var/log/lxd/*/lxc.log',
    rotate        => 90,
    missingok     => true,
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0600',
    rotate_every  => 'day',
  }
}
