#
# @summary This definition installs or removes yum package group.
#
# @param ensure specifies if package group should be present (installed) or absent (purged)
# @param timeout exec timeout for yum groupinstall command
# @param install_options options provided to yum groupinstall command
#
# @example Sample usage:
#   yum::group { 'X Window System':
#     ensure  => 'present',
#   }
#
define yum::group (
  Array[String[1]]                                    $install_options = [],
  Enum['present', 'installed', 'latest', 'absent', 'purged'] $ensure   = 'present',
  Optional[Integer] $timeout                                           = undef,
) {
  Exec {
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    environment => 'LC_ALL=C',
  }

  case $ensure {
    'present', 'installed', default: {
      exec { "yum-groupinstall-${name}":
        command => join(concat(["yum -y groupinstall '${name}'"], $install_options), ' '),
        unless  => "yum grouplist hidden '${name}' | egrep -i '^Installed.+Groups:$'",
        timeout => $timeout,
      }
      if $ensure == 'latest' {
        exec { "yum-groupinstall-${name}-latest":
          command => join(concat(["yum -y groupinstall '${name}'"], $install_options), ' '),
          onlyif  => "yum groupinfo '${name}' | egrep '\\s+\\+'",
          timeout => $timeout,
          require => Exec["yum-groupinstall-${name}"],
        }
      }
    }

    'absent', 'purged': {
      exec { "yum-groupremove-${name}":
        command => "yum -y groupremove '${name}'",
        onlyif  => "yum grouplist hidden '${name}' | egrep -i '^Installed.+Groups:$'",
        timeout => $timeout,
      }
    }
  }
}
