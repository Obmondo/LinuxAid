# LXC class
class lxc(
  Eit_types::IPv4CIDR $network = '10.0.3.0/24',
  String              $bridge = 'lxcbr0',
) {

  # Monitoring
  contain lxc::firewall

  package {'lxc':
    ensure => 'present',
  }

  file {'/usr/share/lxc/templates/lxc-centos':
    ensure  => 'present',
    source  => 'puppet:///modules/lxc/lxc-centos.sh',
    mode    => '0755',
    require => Package['lxc'],
  }

  sysctl::configuration {
    # This specifies an upper limit on the number of events that can be queued
    # to the corresponding inotify instance.
    'fs.inotify.max_queued_events':
      value => '1048576';

    # This specifies an upper limit on the number of inotify instances that can
    # be created per real user ID.
    'fs.inotify.max_user_instances':
      value => '1048576';

    # This specifies an upper limit on the number of watches that can be created
    # per real user ID.
    'fs.inotify.max_user_watches':
      value => '1048576';

    'vm.max_map_count':
      value => '262144';

    # setup lxc nat networking..
    'net.ipv4.ip_forward':
      value => '1';
  }
}
