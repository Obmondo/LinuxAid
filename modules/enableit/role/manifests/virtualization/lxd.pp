# LXD role
class role::virtualization::lxd (
  Boolean $storage                        = true,
  Eit_types::IP $network                  = '10.0.3.0',
  String $lxd_bridge                      = 'lxdbr0',
  Hash[
    Eit_types::SimpleString,
    Struct[{
      os       => String,
      arch     => Optional[String],
      release  => Optional[Variant[String, Integer]],
      state    => Optional[Enum['paused', 'running', 'stopped']],
      ensure   => Enum['present', 'absent'],
      firewall => Optional[Hash],
      config   => Optional[Hash[String,Any]],
      ip       => Optional[Eit_types::IP],
    }]
  ] $instances = {},
  Array[Eit_types::SimpleString] $requires_filesystems = [],
) inherits role::virtualization {

  confine($instances['state'] != 'stopped', $instances['ip'], "Need an IP Address if state is set to ${instances['state']}")

  # should perhaps be abstracted in profile::lxd but currently its our module
  class { '::profile::virtualization::lxd':
    network              => $network,
    lxd_bridge           => $lxd_bridge,
    instances            => $instances,
    requires_filesystems => $requires_filesystems,
  }
}
