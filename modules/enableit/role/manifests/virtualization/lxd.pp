
# @summary Class for managing the LXD virtualization role
#
# @param instances A hash of instances with their configurations. Defaults to an empty hash.
#
# @param requires_filesystems An array of required filesystems. Defaults to an empty array.
#
# @groups config instances, requires_filesystems.
#
class role::virtualization::lxd (
  Hash[    Eit_types::SimpleString,    Struct[{      os       => String,      arch     => Optional[String],      release  => Optional[Variant[String, Integer]],      state    => Optional[Enum['paused', 'running', 'stopped']],      ensure   => Enum['present', 'absent'],      firewall => Optional[Hash],      config   => Optional[Hash[String,Any]],      ip       => Optional[Eit_types::IP],    }]  ] $instances = {},
  Array[Eit_types::SimpleString] $requires_filesystems = [],
) inherits role::virtualization {

  confine($instances['state'] != 'stopped', $instances['ip'], "Need an IP Address if state is set to ${instances['state']}")  # should perhaps be abstracted in profile::lxd but currently its our module

  class { '::profile::virtualization::lxd':
    instances            => $instances,
    requires_filesystems => $requires_filesystems,
  }
}
