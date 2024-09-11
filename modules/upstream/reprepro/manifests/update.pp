# == Definition: reprepro::update
#
#   Adds a packages repository.
#
# === Parameters
#
#   - *name*: the name of the update-upstream use in the
#             Update field in conf/distributions
#   - *ensure*: present/absent, defaults to present
#   - *suite*: package suite
#   - *url*: a valid repository URL
#   - *verify_release*: check the GPG signature Releasefile
#   - *filter_action*: default action when something is not found in the list
#   - *filter_name*: Name of a filter list created with reprepro::filterlist, matching binary packages
#   - *filter_src_name: Name of a filter list created with reprepro::filterlist, matching source packages
#   - *download_lists_as: specify in which order reprepro will look for a usable variant of needed index
#     files ( .gz, .bz2, .lzma, .xz and .diff)
#   - *getinrelease: if this is set to 'no', no InRelease file is downloaded but
#     only Release (and Release.gpg ) are tried.
#
# === Requires
#
#   - Class["reprepro"]
#
# === Example
#
#   reprepro::update {"lenny-backports":
#     ensure      => present,
#     suite       => 'lenny',
#     repository  => "dev",
#     url         => 'http://backports.debian.org/debian-backports',
#     filter_name => "lenny-backports",
#   }
#
define reprepro::update (
  $suite,
  $repository,
  $url,
  $basedir = $::reprepro::basedir,
  $ensure = present,
  $architectures = undef,
  $components = undef,
  $udebcomponents = undef,
  $flat = undef,
  $verify_release = 'blindtrust',
  $ignore_release = 'No',
  $filter_action = '',
  $filter_name = '',
  $filter_src_name='',
  $download_lists_as='',
  $getinrelease=undef,
) {

  include reprepro::params
  include concat::setup

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
    Reprepro::Filterlist[$filter_name] -> Concat::Fragment["update-${name}"]
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
    Reprepro::Filterlist[$filter_src_name] -> Concat::Fragment["update-${name}"]
  } else {
    $filter_src_list = ''
  }

  $manage = $ensure ? {
    'present' => false,
    default => true,
  }

  concat::fragment {"update-${name}":
    ensure  => $ensure,
    content => template('reprepro/update.erb'),
    target  => "${basedir}/${repository}/conf/updates",
  }
}
