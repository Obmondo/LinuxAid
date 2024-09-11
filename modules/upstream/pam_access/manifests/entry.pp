# Define: pam_access::entry
#
# Parameters:
#
#   $ensure = present (default), absent
#
#     If $ensure is present, an access.conf entry will be created; otherwise, one
#     (or more) will be removed.
#
#   $user = username, (groupname), ALL (EXCEPT)
#
#     Supply a valid user/group specification.
#
#   $origin = tty, hostname, domainname, address, ALL, LOCAL
#
#     Supply a valid origin specification.
#
#   $group = true, false (default)
#
#     If $group is true, the user specification $user will be interpreted as
#     a group name.
#
# Actions:
#
#   Creates an augeas resource to create or remove
#
# Requires:
#
#   Augeas >= 0.8.0 (access.conf lens is not present in earlier releases)
#
# Sample Usage:
#
#   pam_access::entry {
#     "mailman-cron":
#       user   => "mailman",
#       origin => "cron";
#     "root-localonly":
#       permission => "-",
#       user       => "root",
#       origin     => "ALL EXCEPT LOCAL";
#     "lusers-revoke-access":
#       ensure => absent,
#       user   => "lusers",
#       group  => true;
#   }
#
define pam_access::entry (
  Enum['absent', 'present']         $ensure     = present,
  Enum['+', '-']                    $permission = '+',
  Variant[Boolean, String]          $user       = false,
  Variant[Boolean, String]          $group      = false,
  String                            $origin     = 'LOCAL',
  Optional[Enum['after', 'before']] $position   = undef,
) {

  include ::pam_access

  if $user and $group {
    fail("\$pam_access::entry::user and \$pam_access::entry::group can not both be set")
  }

  if !($user or $group) {
    fail('Either $user or $group must be set')
  }

  $_position = if $position {
    $position
  } else {
    $permission ? {
      '+' => 'before',
      '-' => 'after',
    }
  }

  Augeas {
    context => '/files/etc/security/access.conf/',
    incl    => '/etc/security/access.conf',
    lens    => 'Access.lns',
  }

  if $pam_access::manage_pam {
    Augeas {
      notify => Class['pam_access::pam'],
    }
  }

  $_perm_str = if $user {
    if $user =~ Boolean {
      $title
    } else {
      $user
    }
  } else {
    if $group =~ Boolean {
      $title
    } else {
      $group
    }
  }

  $_context = if $user {
    'user'
  } else {
    'group'
  }

  case $ensure {
    'present': {
      $create_cmds = $_position ? {
        'after'  => [
          "set access[last()+1] ${permission}",
          "set access[last()]/${_context} ${_perm_str}",
          "set access[last()]/origin ${origin}",
        ],
        'before' => [
          'ins access before access[1]',
          "set access[1] ${permission}",
          "set access[1]/${_context} ${_perm_str}",
          "set access[1]/origin ${origin}",
        ],
        '-1'     => [
          'ins access before access[last()]',
          "set access[last()-1] ${permission}",
          "set access[last()-1]/${_context} ${_perm_str}",
          "set access[last()-1]/origin ${origin}",
        ],
      }

      augeas { "pam_access/${_context}/${permission}:${_perm_str}:${origin}/${ensure}":
        changes => $create_cmds,
        onlyif  => "match access[. = '${permission}'][${_context} = '${_perm_str}'][origin = '${origin}'] size == 0",
      }
    }
    'absent': {
      augeas { "pam_access/${_context}/${permission}:${_perm_str}:${origin}/${ensure}":
        changes => [
          "rm access[. = '${permission}'][${_context} = '${_perm_str}'][origin = '${origin}']",
        ],
        onlyif  => "match access[. = '${permission}'][${_context} = '${_perm_str}'][origin = '${origin}'] size > 0",
      }
    }
    # Unreachable due to the types, but included to make the linter happy...
    default: { fail("Invalid ensure: ${ensure}") }
  }

}
