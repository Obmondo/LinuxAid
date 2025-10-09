# Class: zypprepo::plugin::versionlock
#
# @summary This class sets the structure for the lock file
#
# @param path
#   Absolute path to the Zypper locks file. Defaults /etc/zypp/locks.
#
# @example Sample usage:
#   include zypprepo::plugin::versionlock
#
class zypprepo::plugin::versionlock (
  Stdlib::Absolutepath      $path   = '/etc/zypp/locks',
) {
  concat { $path:
    mode  => '0644',
    owner => 'root',
    group => 'root',
  }

  concat::fragment { 'versionlock_header':
    target  => $path,
    content => '# File managed by puppet\n',
    order   => '01',
  }
}
