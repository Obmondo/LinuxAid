#
# @summary This class installs versionlock plugin
#
# @param ensure specifies if versionlock should be present or absent
# @param clean specifies if yum clean all should be called after edits. Defaults false.
# @param path filepath for the versionlock.list, default based on your system.
#
# @example Sample usage:
#   class { 'yum::plugin::versionlock':
#     ensure      => present,
#   }
#
class yum::plugin::versionlock (
  String                    $path,
  Enum['present', 'absent'] $ensure   = 'present',
  Boolean                   $clean    = false,
) {
  $pkg_prefix = $facts['package_provider'] ? {
    'dnf'   => 'python3-dnf-plugin',
    'yum'   => 'yum-plugin',
    default => '',
  }

  yum::plugin { 'versionlock':
    ensure     => $ensure,
    pkg_prefix => $pkg_prefix,
  }

  if $ensure == 'present' {
    include yum::clean
    $_clean_notify = $clean ? {
      true  => Exec['yum_clean_all'],
      false => undef,
    }

    concat { $path:
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      notify => $_clean_notify,
    }

    concat::fragment { 'versionlock_header':
      target  => $path,
      content => "# File managed by puppet\n",
      order   => '01',
    }
  }
}
