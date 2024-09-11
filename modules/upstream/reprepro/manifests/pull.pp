# == Definition: reprepro::pull
#
# Add a repository pull rule.
#
# Parameters:
# - *name*: the name of the pull rule to use in the Pull
#   field in conf/distributions
# - *ensure*: present/absent, defaults to present
# - *repository*: the local repository to pull to
# - *from*: The codename of the distribution to pull packages from.
# - *components*: The components of the distribution to get from.
# - *architectures*: The architectures to update.
# - *udebcomponents*: Like Components but for the udebs.
# - *filter_action*: default action when something is not found in the list
# - *filter_name*: a list of filenames in the format of dpkg --get-selections
# - *filter_src_list: FilterSrcList parameter
# - *filter_formula*: FilterFormula
# - *basedir*: basedir for installation
#
# Requires:
# - Class['reprepro']
#
# Example usage:
#
#   reprepro::pull {'lenny-backports':
#     ensure      => 'present',
#     repository  => 'localpkgs',
#     from        => 'dev',
#     filter_name => 'lenny-backports',
#     basedir     => '/srv/reprepro',
#   }
#
define reprepro::pull (
  $ensure          = 'present',
  $repository,
  $from,
  $basedir         = $::reprepro::basedir,
  $components      = '',
  $architectures   = '',
  $udebcomponents  = '',
  $filter_action   = '',
  $filter_name     = '',
  $filter_src_name = '',
  $filter_formula  = '',
) {

  include reprepro::params

  if $filter_name != '' {
    if $filter_action == '' {
      $filter_list = "deinstall ${filter_name}-filter-list"
    } else {
      $filter_list = "${filter_action} ${filter_name}-filter-list"
    }
    # Add dependency on filter list
    Reprepro::Filterlist[$filter_name] -> Concat::Fragment["pulls-${name}"]
  } else {
    $filter_list = ''
  }

  if $filter_src_name != '' {
    if $filter_action == '' {
      $filter_src_list = "deinstall ${filter_src_name}-filter-list"
    } else {
      $filter_src_list = "${filter_action} ${filter_src_name}-filter-list"
    }
    # Add dependency on filter list
    Reprepro::Filterlist[$filter_src_name] -> Concat::Fragment["pulls-${name}"]
  } else {
    $filter_src_list = ''
  }

  concat::fragment {"pulls-${name}":
    ensure  => $ensure,
    target  => "${basedir}/${repository}/conf/pulls",
    content => template('reprepro/pull.erb'),
  }
}
