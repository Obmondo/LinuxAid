#
# Adds a FilterList
#
# Packages list have the same syntax as the output of dpkg --get-selections
#
# @param list_name
#   name of the filter list
# @param ensure
#   present/absent, defaults to present
# @param repository
#   the name of the repository
# @param packages
#   a list of packages, if the list is empty, the file
#   content won't be managed by puppet
#
# @example
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
#
define reprepro::filterlist (
  String $repository,
  String $list_name = $title,
  Array  $packages  = [],
  String $ensure    = 'present',
) {

  include reprepro

  if (size($packages) > 0) {
    file {"${reprepro::basedir}/${repository}/conf/${list_name}-filter-list":
      ensure  => $ensure,
      owner   => 'root',
      group   => $::reprepro::group_name,
      mode    => '0664',
      content => template('reprepro/filterlist.erb'),
    }
  } else {
    file {"${reprepro::basedir}/${repository}/conf/${list_name}-filter-list":
      ensure  => $ensure,
      owner   => 'root',
      group   => $::reprepro::group_name,
      mode    => '0664',
      replace => false,
    }
  }
}
