# == Definition: reprepro::filterlist
#
#   Adds a FilterList
#
# === Parameters
#
#   - *name*: name of the filter list
#   - *ensure*: present/absent, defaults to present
#   - *repository*: the name of the repository
#   - *packages*: a list of packages, if the list is empty, the file
#                 content won't be managed by puppet
#
# === Requires
#
#   - Class["reprepro"]
#
# === Example
#
#   reprepro::filterlist {"lenny-backports":
#     ensure     => present,
#     repository => "dev",
#     packages   => [
#       "git install",
#       "git-email install",
#       "gitk install",
#     ],
#   }
#
# === Warning
#
#   - Packages list have the same syntax as the output of dpkg --get-selections
#
define reprepro::filterlist (
  $repository,
  $packages = [],
  $basedir = $::reprepro::basedir,
  $ensure=present,
) {

  include reprepro::params

  if (size($packages) > 0) {
    file {"${basedir}/${repository}/conf/${name}-filter-list":
      ensure  => $ensure,
      owner   => 'root',
      group   => $::reprepro::group_name,
      mode    => '0664',
      content => template('reprepro/filterlist.erb'),
    }
  } else {
    file {"${basedir}/${repository}/conf/${name}-filter-list":
      ensure  => $ensure,
      owner   => 'root',
      group   => $::reprepro::group_name,
      mode    => '0664',
      replace => false,
    }
  }
}
