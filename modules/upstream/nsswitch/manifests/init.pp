# @summary nsswitch class
#   This module creates a /etc/nsswitch.conf file whith all the lines that
#   determine the sources from which to obtain name-service information in a
#   range of categories, and in what order. For further information look into
#   manual pages.
#
# @example Basic example
#    include nsswitch
#
#    class { 'nsswitch':
#      passwd => ['ldap','files'],
#      hosts  => ['dns [!UNAVAIL=return]','files'],
#    }
#
# @param aliases
#
#   Mail aliases, used by getaliasent() and related functions.
#   *Variant* (defaults to $nsswitch::params::aliases_default)
#
# @param automount
#
#   Which conventions to use for automounting of homes.
#   *Variant* (defaults to $nsswitch::params::automount_default)
#
# @param bootparams
#
#   Where bootparams shall be supplied from (e.g. for diskless clients at boot
#   time using rpc.bootparamd).
#   *Variant* (defaults to $nsswitch::params::bootparams_default)
#
# @param ethers
#
#   Ethernet numbers.
#   *Variant* (defaults to $nsswitch::params::ethers_default)
#
# @param file_group
#
#   Group of the nsswitch.conf file
#   *Optional* (defaults to $nsswitch::params::file_group)
#
# @param file_owner
#
#   Owner of the nsswitch.conf file
#   *Optional* (defaults to $nsswitch::params::file_owner)
#
# @param file_perms
#
#   Permissions for the nsswitch.conf file
#   *Optional* (defaults to $nsswitch::params::file_perms)
#
# @param group
#
#   Groups of users, used by getgrent() and related functions.
#   *Variant* (defaults to $nsswitch::params::group_default)
#
# @param gshadow
#
#   Shadow groups, used by getspnam() and related functions.
#   *Variant* (defaults to $nsswitch::params::gshadow_default)
#
# @param hosts
#
#   Host names and numbers, used by gethostbyname() and related functions.
#   *Variant* (defaults to $nsswitch::params::hosts_default)
#
# @param netgroup
#
#   Network-wide list of hosts and users, used for access rules.
#   *Variant* (defaults to $nsswitch::params::netgroup_default)
#
# @param netmasks
#
#   Netmasks specify how much of the address to reserve for sub-dividing
#   networks into subnetworks.
#   *Variant* (defaults to $nsswitch::params::netmasks_default)
#
# @param networks
#
#   Network names and numbers, used by getnetent() and related functions.
#   *Variant* (defaults to $nsswitch::params::network_default)
#
# @param passwd
#
#   User passwords, used by getpwent() and related functions.
#   *Variant* (defaults to $nsswitch::params::passwd_default)
#
# @param protocols
#
#   Network protocols, used by getprotoent() and related functions.
#   *Variant* (defaults to $nsswitch::params::protocols_default)
#
# @param publickey
#
#   Public and secret keys for Secure_RPC used by NFS and NIS+.
#   *Variant* (defaults to $nsswitch::params::rpc_default)
#
# @param services
#
#   Remote procedure call names and numbers, used by getrpcbyname() and related
#   functions.
#   *Variant* (defaults to $nsswitch::params::rpc_default)
#
# @param services
#
#   Network services, used by getservent() and related functions.
#   *Variant* (defaults to $nsswitch::params::services_default)
#
# @param shadow
#
#   Shadow user passwords, used by getspnam() and related functions.
#   *Variant* (defaults to $nsswitch::params::shadow_default)
#
# @param shells
#
#   Valid user shells, used by getusershell() and related functions.
#   *Optional* (defaults to $nsswitch::params::shells_default)
#
# @param sudoers
#
#   Sudoers policy module users.
#   *Variant* (defaults to $nsswitch::params::sudoers_default)
#
class nsswitch (
  Variant[String, Array, Undef] $aliases    = $nsswitch::params::aliases_default,
  Variant[String, Array, Undef] $automount  = $nsswitch::params::automount_default,
  Variant[String, Array, Undef] $bootparams = $nsswitch::params::bootparams_default,
  Variant[String, Array, Undef] $ethers     = $nsswitch::params::ethers_default,
  Variant[String, Undef] $file_group        = $nsswitch::params::file_group,
  Variant[String, Undef] $file_owner        = $nsswitch::params::file_owner,
  Variant[String, Undef] $file_perms        = $nsswitch::params::file_perms,
  Variant[String, Array, Undef] $group      = $nsswitch::params::group_default,
  Variant[String, Array, Undef] $hosts      = $nsswitch::params::hosts_default,
  Variant[String, Array, Undef] $netgroup   = $nsswitch::params::netgroup_default,
  Variant[String, Array, Undef] $netmasks   = $nsswitch::params::netmasks_default,
  Variant[String, Array, Undef] $networks   = $nsswitch::params::networks_default,
  Variant[String, Array, Undef] $passwd     = $nsswitch::params::passwd_default,
  Variant[String, Array, Undef] $protocols  = $nsswitch::params::protocols_default,
  Variant[String, Array, Undef] $publickey  = $nsswitch::params::publickey_default,
  Variant[String, Array, Undef] $rpc        = $nsswitch::params::rpc_default,
  Variant[String, Array, Undef] $services   = $nsswitch::params::services_default,
  Variant[String, Array, Undef] $shadow     = $nsswitch::params::shadow_default,
  Variant[String, Array, Undef] $shells     = $nsswitch::params::shells_default,
  Variant[String, Array, Undef] $gshadow    = $nsswitch::params::gshadow_default,
  Variant[String, Array, Undef] $sudoers    = $nsswitch::params::sudoers_default,
) inherits nsswitch::params {

  file { 'nsswitch.conf':
    ensure  => file,
    path    => '/etc/nsswitch.conf',
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_perms,
    content => epp('nsswitch/nsswitch.conf.epp'),
  }
}
