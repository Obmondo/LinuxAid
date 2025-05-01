# @summary Manages the system nsswitch.conf configuration
#
# This module creates a `nsswitch.conf` file with all the lines that determine
# the sources from which to obtain name-service information in a range of
# categories, and in what order.
#
# @see nsswitch.conf(5)
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
#   Mail aliases, used by getaliasent() and related functions.
#
# @param automount
#   Which conventions to use for automounting of homes.
#
# @param bootparams
#   Where bootparams shall be supplied from (e.g. for diskless clients at boot
#   time using rpc.bootparamd).
#
# @param ethers
#   Ethernet numbers.
#
# @param file_group
#   Group of the nsswitch.conf file
#
# @param file_owner
#   Owner of the nsswitch.conf file
#
# @param file_perms
#   Permissions for the nsswitch.conf file
#
# @param group
#   Groups of users, used by getgrent() and related functions.
#
# @param gshadow
#   Shadow groups, used by getspnam() and related functions.
#
# @param hosts
#   Host names and numbers, used by gethostbyname() and related functions.
#
# @param netgroup
#   Network-wide list of hosts and users, used for access rules.
#
# @param netmasks
#   Netmasks specify how much of the address to reserve for sub-dividing
#   networks into subnetworks.
#
# @param networks
#   Network names and numbers, used by getnetent() and related functions.
#
# @param passwd
#   User passwords, used by getpwent() and related functions.
#
# @param protocols
#   Network protocols, used by getprotoent() and related functions.
#
# @param publickey
#   Public and secret keys for Secure_RPC used by NFS and NIS+.
#
# @param rpc
#   Remote procedure call names and numbers, used by getrpcbyname() and related
#   functions.
#
# @param services
#   Network services, used by getservent() and related functions.
#
# @param shadow
#   Shadow user passwords, used by getspnam() and related functions.
#
# @param shells
#   Valid user shells, used by getusershell() and related functions.
#
# @param sudoers
#   Sudoers policy module users.
#
# @param file_path
#   The path to `nsswitch.conf` on the system.
class nsswitch (
  Optional[Variant[String, Array]] $aliases    = $nsswitch::params::aliases_default,
  Optional[Variant[String, Array]] $automount  = $nsswitch::params::automount_default,
  Optional[Variant[String, Array]] $bootparams = $nsswitch::params::bootparams_default,
  Optional[Variant[String, Array]] $ethers     = $nsswitch::params::ethers_default,
  Optional[Variant[String]]        $file_group = $nsswitch::params::file_group,
  Variant[String]                  $file_owner = 'root',
  Variant[String]                  $file_perms = '0644',
  Optional[Variant[String, Array]] $group      = $nsswitch::params::group_default,
  Optional[Variant[String, Array]] $hosts      = $nsswitch::params::hosts_default,
  Optional[Variant[String, Array]] $netgroup   = $nsswitch::params::netgroup_default,
  Optional[Variant[String, Array]] $netmasks   = $nsswitch::params::netmasks_default,
  Optional[Variant[String, Array]] $networks   = $nsswitch::params::networks_default,
  Optional[Variant[String, Array]] $passwd     = $nsswitch::params::passwd_default,
  Optional[Variant[String, Array]] $protocols  = $nsswitch::params::protocols_default,
  Optional[Variant[String, Array]] $publickey  = $nsswitch::params::publickey_default,
  Optional[Variant[String, Array]] $rpc        = $nsswitch::params::rpc_default,
  Optional[Variant[String, Array]] $services   = $nsswitch::params::services_default,
  Optional[Variant[String, Array]] $shadow     = $nsswitch::params::shadow_default,
  Optional[Variant[String, Array]] $shells     = $nsswitch::params::shells_default,
  Optional[Variant[String, Array]] $gshadow    = $nsswitch::params::gshadow_default,
  Optional[Variant[String, Array]] $sudoers    = $nsswitch::params::sudoers_default,
  Stdlib::Unixpath                 $file_path  = '/etc/nsswitch.conf'
) inherits nsswitch::params {

  file { 'nsswitch.conf':
    ensure  => file,
    path    => $file_path,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_perms,
    content => epp('nsswitch/nsswitch.conf.epp'),
  }
}
