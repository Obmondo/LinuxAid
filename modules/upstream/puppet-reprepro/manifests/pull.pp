#
# Add a repository pull rule.
#
# @param name
#   the name of the pull rule to use in the Pull
#   field in conf/distributions
# @param repository
#   the local repository to pull to
# @param from
#   The codename of the distribution to pull packages from.
# @param components
#   The components of the distribution to get from.
# @param architectures
#   The architectures to update.
# @param udebcomponents
#   Like Components but for the udebs.
# @param filter_action
#   default action when something is not found in the list
# @param filter_name
#   a list of filenames in the format of dpkg --get-selections
# @param filter_src_name
#   FilterSrcList parameter
# @param filter_formula
#   FilterFormula
#
# @example
#   reprepro::pull {'lenny-backports':
#     repository  => 'localpkgs',
#     from        => 'dev',
#     filter_name => 'lenny-backports',
#   }
#
define reprepro::pull (
  String $repository,
  String $from,
  String $components      = '',
  String $architectures   = '',
  String $udebcomponents  = '',
  String $filter_action   = '',
  String $filter_name     = '',
  String $filter_src_name = '',
  String $filter_formula  = '',
) {

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
    target  => "${reprepro::basedir}/${repository}/conf/pulls",
    content => template('reprepro/pull.erb'),
  }
}
