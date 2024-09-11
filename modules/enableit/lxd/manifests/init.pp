# LXD provider
#
# ISSUES:
#  - no way of changing config once container is created
#  - doesn't handle multiple lxd storage backends
#  - missing provider for lxc_image (to add remote image directories)
#  - can't brew coffee
#
# DEMO:
#
# $ puppet resource lxc
# >>> lxc { 'android':
# >>>   ensure   => 'present',
# >>>   os       => 'Archlinux',
# >>>   profiles => ['default'],
# >>>   release  => 'current',
# >>>   serial   => '20170505_01:27',
# >>>   state    => 'stopped',
# >>> }
# >>> lxc { 'puppet-dev':
# >>>   ensure   => 'present',
# >>>   os       => 'ubuntu',
# >>>   profiles => ['default'],
# >>>   release  => 'xenial',
# >>>   serial   => '20170815.1',
# >>>   state    => 'stopped',
# >>> }
# >>> lxc { 'test':
# >>>   ensure   => 'present',
# >>>   os       => 'ubuntu',
# >>>   profiles => ['default'],
# >>>   release  => 'trusty',
# >>>   serial   => '20170831',
# >>>   state    => 'running',
# >>> }
#
# $ puppet resource lxc test-trusty ensure=present release=trusty \
#          state=stopped config='limits.memory=56MB,limits.memory.swap=false'
# >>> Notice: /Lxc[test-trusty]/ensure: created
# >>> lxc { 'test-trusty':
# >>>   ensure   => 'present',
# >>>   os       => 'ubuntu',
# >>>   profiles => ['default'],
# >>>   release  => 'trusty',
# >>>   state    => 'stopped',
# >>> }
class lxd (
  Eit_types::IP $network               = '10.0.3.0',
  String $lxd_bridge                   = 'lxdbr0',
  Boolean $manage_firewall             = true,
  Boolean $manage_logrotate            = true,
  Array[Eit_types::SimpleString] $requires_filesystems = [],
) {

  package { ['lxd', 'lxd-client']:
    ensure => 'present',
  }

  $_requires_filesystems = $requires_filesystems.map |$fs| {
    Common::Device::Filesystem[$fs]
  }

  # Push firewall rules
  if $manage_firewall {
    contain lxd::firewall
  }

  # Setup logrotate for lxd and lxd-lxcee
  if $manage_logrotate {
    include lxd::logrotate
  }

  file {
    default:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['lxd'],
    ;

    ['/etc/lxd', '/etc/lxd/dnsmasq.conf.d']:
      ensure => directory,
    ;
  }

  ini_setting {
    'lxd dnsmasq config file':
      ensure  => present,
      path    => '/etc/default/lxd-bridge',
      setting => 'LXD_CONFILE',
      value   => '/etc/lxd/dnsmasq.conf',
    ;

    'lxd dnsmasq config dir':
      ensure  => present,
      path    => '/etc/lxd/dnsmasq.conf',
      setting => 'conf-dir',
      value   => '/etc/lxd/dnsmasq.conf.d,*.conf',
    ;
  }

  # Production configuration based on
  # https://github.com/lxc/lxd/blob/9df95a9197797562aab57d0c9e784b3c8a68f84e/doc/production-setup.md
  sysctl::configuration {
    # This specifies an upper limit on the number of events that can be queued
    # to the corresponding inotify instance.
    'fs.inotify.max_queued_events':
      value => '1048576',
    ;

    # This specifies an upper limit on the number of inotify instances that can
    # be created per real user ID.
    'fs.inotify.max_user_instances':
      value => '1048576',
    ;

    # This specifies an upper limit on the number of watches that can be created
    # per real user ID.
    'fs.inotify.max_user_watches':
      value => '1048576',
    ;

    'vm.max_map_count':
      value => '262144',
    ;

  }

  # If $requires_filesystems has entries lookup the defined filesystems so we
  # can make sure that they exist.
  $_filesystems = if Boolean(size($requires_filesystems)) {
    lookup('common::devices::filesystems', Hash, 'hash', undef)
  }

  # Make lxd-containers depend on the required filesystems, if any. Filesystems
  # refer to devices instantiated with our own services. These are named
  # `disk@%i.service`.
  $_service_units = $requires_filesystems.reduce([]) |$acc, $name| {
    $filesystem = $_filesystems[$name]

    unless $filesystem {
      fail("Required filesystem '${name}' is not defined.")
    }

    $_service = "${filesystem['type']}-mount-${name}.service"

    $acc + [
      {'After' => $_service},
      {'BindsTo' => $_service},
    ]
  }

  common::services::systemd { 'lxd-containers.service':
    override => true,
    unit     => flatten($_service_units),
  }


}
