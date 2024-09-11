#
# Adds a packages repository.
#
# @param update_name
#   the name of the update-upstream use in the
#   Update field in conf/distributions
# @param suite
#   package suite
# @param repository
#   the name of the repository
# @param url
#   a valid repository URL
# @param architectures
#   architectures
# @param components
#   components
# @param udebcomponents
#   udebcomponents
# @param flat
#   flat
# @param verify_release
#   check the GPG signature Releasefile
# @param ignore_release
#   ignore_release
# @param filter_action
#   default action when something is not found in the list
# @param filter_name
#   Name of a filter list created with reprepro::filterlist,
#   matching binary packages
# @param filter_src_name
#   Name of a filter list created with reprepro::filterlist,
#   matching source packages
# @param download_lists_as
#   specify in which order reprepro will look for a usable
#   variant of needed index files ( .gz, .bz2, .lzma, .xz and .diff)
# @param getinrelease
#   if this is set to 'no', no InRelease file is downloaded but
#   only Release (and Release.gpg ) are tried.
#
# @example
#   reprepro::update {"lenny-backports":
#     suite       => 'lenny',
#     repository  => "dev",
#     url         => 'http://backports.debian.org/debian-backports',
#     filter_name => "lenny-backports",
#   }
#
define reprepro::update (
  String           $suite,
  String           $repository,
  String           $url,
  String           $update_name       = $title,
  Optional[String] $architectures     = undef,
  Optional[String] $components        = undef,
  Optional[String] $udebcomponents    = undef,
  Optional[String] $flat              = undef,
  String           $verify_release    = 'blindtrust',
  String           $ignore_release    = 'No',
  String           $filter_action     = '',
  String           $filter_name       = '',
  String           $filter_src_name   = '',
  String           $download_lists_as = '',
  Optional[String] $getinrelease      = undef,
) {

  include reprepro

  if $flat and ($components or $udebcomponents) {
    fail('$components and $udebcomponents are not allowed when $flat is provided.')
  }

  if $filter_name != '' {
    if $filter_action == '' {
      $filter_list = "deinstall ${filter_name}-filter-list"
    } else {
      $filter_list = "${filter_action} ${filter_name}-filter-list"
    }
    # Add dependency on filter list
    Reprepro::Filterlist[$filter_name] -> Concat::Fragment["update-${update_name}"]
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
    Reprepro::Filterlist[$filter_src_name] -> Concat::Fragment["update-${update_name}"]
  } else {
    $filter_src_list = ''
  }

  concat::fragment {"update-${update_name}":
    content => template('reprepro/update.erb'),
    target  => "${reprepro::basedir}/${repository}/conf/updates",
  }
}
