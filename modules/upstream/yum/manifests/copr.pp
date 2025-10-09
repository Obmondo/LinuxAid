#
# @summary This definition manages Copr (Cool Other Package Repo) repositories.
#
# @param copr_repo
#   Name of repository, defaults to title.
# @param manage_prereq_plugin
#   Wheter required plugin for dnf/yum should be installed by this resource.
# @param ensure
#   Specifies if repo should be enabled, disabled or removed.
#
# @example add and enable COPR restic repository
#   yum::copr { 'copart/restic':
#     ensure  => 'enabled',
#   }
#
define yum::copr (
  String                                 $copr_repo            = $title,
  Boolean                                $manage_prereq_plugin = true,
  Enum['enabled', 'disabled', 'removed'] $ensure               = 'enabled',
) {
  $prereq_plugin = $facts['package_provider'] ? {
    'dnf'   => 'dnf-plugins-core',
    default => 'yum-plugin-copr',
  }
  if $manage_prereq_plugin {
    stdlib::ensure_packages([$prereq_plugin])
  }

  if $facts['package_provider'] == 'dnf' {
    $copr_name = regsubst($copr_repo, '@', 'group_')
    case $ensure {
      'enabled': {
        exec { "dnf -y copr enable ${copr_repo}":
          path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          unless  => "dnf copr list | egrep -q '${copr_name}\$'",
          require => Package[$prereq_plugin],
        }
      }
      'disabled': {
        exec { "dnf -y copr disable ${copr_repo}":
          path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          unless  => "dnf copr list | egrep -q '${copr_name} \\(disabled\\)\$'",
          require => Package[$prereq_plugin],
        }
      }
      'removed': {
        exec { "dnf -y copr remove ${copr_repo}":
          path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          onlyif  => "dnf copr list | egrep -q '${copr_name}'",
          require => Package[$prereq_plugin],
        }
      }
      default: {
        fail("The value for ensure for `yum::copr` must be enabled, disabled or removed, but it is ${ensure}.")
      }
    }
  } else {
    $copr_repo_name_part = regsubst($copr_repo, '/', '-', 'G')
    case $ensure {
      'enabled': {
        exec { "yum -y copr enable ${copr_repo}":
          path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          onlyif  => "test ! -e /etc/yum.repos.d/_copr_${copr_repo_name_part}.repo",
          require => Package[$prereq_plugin],
        }
      }
      'disabled', 'removed': {
        exec { "yum -y copr disable ${copr_repo}":
          path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
          onlyif  => "test -e /etc/yum.repos.d/_copr_${copr_repo_name_part}.repo",
          require => Package[$prereq_plugin],
        }
      }
      default: {
        fail("The value for ensure for `yum::copr` must be enabled, disabled or removed, but it is ${ensure}.")
      }
    }
  }
}
