# nsswitch
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
  # non-essential options have defaults set; don't set defaults for the
  # remaining options unless you're sure it won't break things!
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
