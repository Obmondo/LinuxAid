# ssh_keygen
#
# @summary Generate ssh keys for a user resource using ssh_keygen.
#
# @example Generate ssh keys for any user using ssh_keygen. The user must exist before using the module
#  ssh_keygen { 'john': }
#
# @example If not using the default `/home/john`
#  ssh_keygen { 'john':
#    home => '/var/home'
#  }
#
# @example The key comment can also be overriden with
#  ssh_keygen { 'john':
#    comment => 'john key'
#  }

# @example Generate a dsa key
#  ssh_keygen { 'john':
#    type => 'dsa'
#  }
#
# @example specify the bit length
#  ssh_keygen { 'john':
#    bits => '4096'
#  }
#
# @example Generate new host key
#  ssh_keygen { 'root':
#    filename => '/etc/ssh/ssh_host_rsa_key'
#  }
#
# @param user Username to create key for
# @param type Type of key to create
# @param bits Number of bits in key
# @param home Home directory for user
# @param filename Key filename
# @param comment Key comment
# @param options Additional options to pass on to ssh-keygen
#
define ssh_keygen (
  Optional[String] $user     = undef,
  Enum['rsa', 'dsa'] $type   = 'rsa',
  Optional[Integer] $bits    = undef,
  Optional[String] $home     = undef,
  Optional[String] $filename = undef,
  Optional[String] $comment  = undef,
  Optional[String] $options  = undef,
) {

  Exec { path => '/bin:/usr/bin' }

  $_user = $user ? {
    undef   => $name,
    default => $user,
  }

  $_home = $home ? {
    undef   => $_user ? {
      'root'  => "/${_user}",
      default => "/home/${_user}",
    },
    default => $home,
  }

  $_filename = $filename ? {
    undef   => "${_home}/.ssh/id_${type}",
    default => $filename,
  }

  $type_opt = " -t ${type}"

  $bits_opt = $bits ? {
    undef   => undef,
    default => " -b ${bits}"
  }

  $filename_opt = " -f '${_filename}'"
  $passphrase_opt = " -N ''"

  $comment_opt = $comment ? {
    undef   => undef,
    default => " -C '${comment}'",
  }

  $options_opt = $options ? {
    undef   => undef,
    default => " ${options}",
  }

  exec { "ssh_keygen-${name}":
    command => "ssh-keygen${type_opt}${bits_opt}${filename_opt}${passphrase_opt}${comment_opt}${options_opt}",
    user    => $_user,
    creates => $_filename,
  }
}
