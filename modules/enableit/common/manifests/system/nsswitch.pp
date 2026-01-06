# @summary Class for managing the nsswitch configuration
#
# @param ethers An array of ethers entries.
#
# @param group An array of group entries.
#
# @param hosts An array of hosts entries.
#
# @param networks An array of networks entries.
#
# @param passwd An array of passwd entries.
#
# @param protocols An array of protocol entries.
#
# @param rpc An array of rpc entries.
#
# @param services An array of services entries.
#
# @param shadow An array of shadow entries.
#
# @param sudoers An array of sudoers entries.
#
# @param manage Boolean indicating whether to manage the resource. Defaults to true.
#
# @param aliases An array of aliases. Defaults to empty array.
#
# @param automount An array of automount entries. Defaults to empty array.
#
# @param bootparams An array of bootparams entries. Defaults to empty array.
#
# @param gshadow An array of gshadow entries. Defaults to empty array.
#
# @param netgroup An array of netgroup entries. Defaults to empty array.
#
# @param netmasks An array of netmasks entries. Defaults to empty array.
#
# @param publickey An array of publickey entries. Defaults to empty array.
#
# @groups authentication passwd, shadow, gshadow, group.
#
# @groups networking ethers, hosts, networks, netmasks.
#
# @groups services protocols, services, rpc, sudoers.
#
# @groups additional aliases, automount, bootparams, netgroup, publickey.
#
# @groups management manage.
#
class common::system::nsswitch (
  Array[String] $ethers,
  Array[String] $group,
  Array[String] $hosts,
  Array[String] $networks,
  Array[String] $passwd,
  Array[String] $protocols,
  Array[String] $rpc,
  Array[String] $services,
  Array[String] $shadow,
  Array[String] $sudoers,
  Boolean       $manage     = true,
  Array[String] $aliases    = [],
  Array[String] $automount  = [],
  Array[String] $bootparams = [],
  Array[String] $gshadow    = [],
  Array[String] $netgroup   = [],
  Array[String] $netmasks   = [],
  Array[String] $publickey  = [],
) {
  if $manage {
    class { '::nsswitch':
      aliases    => $aliases.undef_if_empty,
      automount  => $automount.undef_if_empty,
      bootparams => $bootparams.undef_if_empty,
      ethers     => $ethers.undef_if_empty,
      group      => functions::nsswitch_sort($group).undef_if_empty,
      gshadow    => functions::nsswitch_sort($gshadow).undef_if_empty,
      hosts      => $hosts.undef_if_empty,
      netgroup   => $netgroup.undef_if_empty,
      netmasks   => $netmasks.undef_if_empty,
      networks   => $networks.undef_if_empty,
      passwd     => functions::nsswitch_sort($passwd).undef_if_empty,
      protocols  => $protocols.undef_if_empty,
      publickey  => $publickey.undef_if_empty,
      rpc        => $rpc.undef_if_empty,
      services   => $services.undef_if_empty,
      shadow     => functions::nsswitch_sort($shadow).undef_if_empty,
      sudoers    => $sudoers.undef_if_empty,
    }
  }
}
