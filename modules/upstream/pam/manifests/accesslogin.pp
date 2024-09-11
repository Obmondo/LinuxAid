# @summary Manage login access
#   See PAM_ACCESS(8)
#
# @example
#   This class is included by the pam class for platforms which use it.
#
# @param access_conf_path
#   Path to access.conf.
#
# @param access_conf_owner
#   Owner of access.conf.
#
# @param access_conf_group
#   Group of access.conf.
#
# @param access_conf_mode
#   Mode of access.conf.
#
# @param access_conf_template
#   Content template of access.conf.
#
# @param allowed_users
#   String, Array or Hash of strings and/or arrays to configure users and
#   origins in access.conf. The default allows the root user/group from
#   origin 'ALL'.
#
class pam::accesslogin (
  Stdlib::Absolutepath $access_conf_path      = '/etc/security/access.conf',
  String $access_conf_owner                   = 'root',
  String $access_conf_group                   = 'root',
  Stdlib::Filemode $access_conf_mode          = '0644',
  String $access_conf_template                = 'pam/access.conf.erb',
  Variant[Array, Hash, String] $allowed_users = $pam::allowed_users,
) inherits pam {
  # transform $allowed_users into a valid hash
  # origin defaults to 'ALL' if unset
  # if origin is an array, create a space separated list
  case $allowed_users {
    String: {
      $allowed_users_hash = { $allowed_users => 'ALL' }
    }
    Array: {
      $allowed_users_hash = $allowed_users.reduce({}) |$memo, $x| {
        $memo + { $x => 'ALL' }
      }
    }
    default: {
      $allowed_users_hash = $allowed_users.reduce({}) |$memo, $x| {
        $origin = $x[1] ? {
          String  => $x[1],
          Array   => join($x[1], ' '),
          default => 'ALL',
        }
        $memo + { $x[0] => $origin }
      }
    }
  }

  file { 'access_conf':
    ensure  => file,
    path    => $access_conf_path,
    content => template($access_conf_template),
    owner   => $access_conf_owner,
    group   => $access_conf_group,
    mode    => $access_conf_mode,
    require => Package[$pam::package_name],
  }
}
