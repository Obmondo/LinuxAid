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
# @param subid
#   subuid and subgid mapping
#
# @param file_path
#   The path to `nsswitch.conf` on the system.
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
class nsswitch (
  Optional[Variant[String[1], Array[String[1]]]] $aliases    = undef,
  Optional[Variant[String[1], Array[String[1]]]] $automount  = undef,
  Optional[Variant[String[1], Array[String[1]]]] $bootparams = undef,
  Optional[Variant[String[1], Array[String[1]]]] $ethers     = undef,
  Optional[Variant[String[1], Array[String[1]]]] $group      = undef,
  Optional[Variant[String[1], Array[String[1]]]] $hosts      = undef,
  Optional[Variant[String[1], Array[String[1]]]] $netgroup   = undef,
  Optional[Variant[String[1], Array[String[1]]]] $netmasks   = undef,
  Optional[Variant[String[1], Array[String[1]]]] $networks   = undef,
  Optional[Variant[String[1], Array[String[1]]]] $passwd     = undef,
  Optional[Variant[String[1], Array[String[1]]]] $protocols  = undef,
  Optional[Variant[String[1], Array[String[1]]]] $publickey  = undef,
  Optional[Variant[String[1], Array[String[1]]]] $rpc        = undef,
  Optional[Variant[String[1], Array[String[1]]]] $services   = undef,
  Optional[Variant[String[1], Array[String[1]]]] $shadow     = undef,
  Optional[Variant[String[1], Array[String[1]]]] $shells     = undef,
  Optional[Variant[String[1], Array[String[1]]]] $gshadow    = undef,
  Optional[Variant[String[1], Array[String[1]]]] $sudoers    = undef,
  Optional[Variant[String[1], Array[String[1]]]] $subid      = undef,
  Stdlib::Unixpath $file_path  = '/etc/nsswitch.conf',
  String[1] $file_group = 'root',
  String[1] $file_owner = 'root',
  Stdlib::Filemode $file_perms = '0644',
) {
  file { 'nsswitch.conf':
    ensure  => file,
    path    => $file_path,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_perms,
    content => epp('nsswitch/nsswitch.conf.epp', {
        'aliases'    => $aliases,
        'automount'  => $automount,
        'bootparams' => $bootparams,
        'ethers'     => $ethers,
        'group'      => $group,
        'hosts'      => $hosts,
        'netgroup'   => $netgroup,
        'netmasks'   => $netmasks,
        'networks'   => $networks,
        'passwd'     => $passwd,
        'protocols'  => $protocols,
        'publickey'  => $publickey,
        'rpc'        => $rpc,
        'services'   => $services,
        'shadow'     => $shadow,
        'shells'     => $shells,
        'gshadow'    => $gshadow,
        'sudoers'    => $sudoers,
        'subid'      => $subid,
    }),
  }
}
