#
# Adds a "Distribution" to manage.
#
# @param repository
#   the name of the repository to attach this
#   distribution to.
# @param version
#   distribution version
# @param origin
#   package origin
# @param label
#   package label
# @param suite
#   package suite
# @param architectures
#   available architectures
# @param components
#   available components
# @param description
#   a short description
# @param sign_with
#   email of the gpg key
# @param codename
#   codename (defaults to $title)
# @param fakecomponentprefix
#   fakecomponentprefix
# @param udebcomponents
#   udebcomponents
# @param deb_indices
#   file name and compression
# @param dsc_indices
#   file name and compression
# @param update
#   update policy name
# @param pull
#   pull policy name
# @param uploaders
#   who is allowed to upload packages
# @param snapshots
#   create a reprepro snapshot on each update
# @param install_cron 
#   install cron job to automatically include new packages
# @param not_automatic
#   automatic pined to 1 by using NotAutomatic,
#   value are "yes" or "no"
# @param but_automatic_upgrades
#   set ButAutomaticUpgrades,
#   value are "yes" or "no"
# @param log
#   log
# @param create_pull
#   hash to create reprepro::pull resource
#   the name will be appended to $pull
# @param create_update
#   hash to create reprepro::update resource
#   the name will be appended to $update
# @param create_filterlist
#   hash to create reprerpo::filterlist resource
#
# @example
#   reprepro::distribution {"lenny":
#     repository    => "my-repository",
#     origin        => "Camptocamp",
#     label         => "Camptocamp",
#     suite         => "stable",
#     architectures => "i386 amd64 source",
#     components    => "main contrib non-free",
#     description   => "A simple example of repository distribution",
#     sign_with     => "packages@camptocamp.com",
#   }
#
#
define reprepro::distribution (
  String           $repository,
  String           $architectures,
  String           $components,
  Optional[String] $version                = undef,
  Optional[String] $origin                 = undef,
  Optional[String] $label                  = undef,
  Optional[String] $suite                  = undef,
  Optional[String] $description            = undef,
  String           $sign_with              = '',
  String           $codename               = $title,
  Optional[String] $fakecomponentprefix    = undef,
  String           $udebcomponents         = $components,
  String           $deb_indices            = 'Packages Release .gz .bz2',
  String           $dsc_indices            = 'Sources Release .gz .bz2',
  String           $update                 = '',
  String           $pull                   = '',
  String           $uploaders              = '',
  Boolean          $snapshots              = false,
  Boolean          $install_cron           = true,
  String           $not_automatic          = '',
  String           $but_automatic_upgrades = 'no',
  String           $log                    = '',
  Hash             $create_pull            = {},
  Hash             $create_update          = {},
  Hash             $create_filterlist      = {},
) {

  include reprepro

  # create update and pull resources:
  $_pull   = join(union([$pull],   keys($create_pull)),   ' ')
  $_update = join(union([$update], keys($create_update)), ' ')
  $defaults = {
    repository => $repository,
  }
  create_resources('::reprepro::update', $create_update, $defaults)
  create_resources('::reprepro::pull', $create_pull, $defaults)
  create_resources('::reprepro::filterlist', $create_filterlist, $defaults)

  concat::fragment { "distribution-${title}":
    target  => "${reprepro::basedir}/${repository}/conf/distributions",
    content => template('reprepro/distribution.erb'),
    notify  => Exec["export distribution ${title}"],
  }

  exec {"export distribution ${title}":
    command     => "su -c 'reprepro -b ${reprepro::basedir}/${repository} export ${codename}' ${reprepro::user_name}",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    logoutput   => on_failure,
    require     => Concat["${reprepro::basedir}/${repository}/conf/distributions"],
    tag         => 'reprepro-distribution',
  }

  # Configure system for automatically adding packages
  file { "${reprepro::basedir}/${repository}/tmp/${codename}":
    ensure => directory,
    mode   => '0755',
    owner  => $::reprepro::user_name,
    group  => $::reprepro::group_name,
  }

  if $install_cron {

    if $snapshots {
      $command = "${reprepro::homedir}/bin/update-distribution.sh -r ${repository} -c ${codename} -s"
    } else {
      $command = "${reprepro::homedir}/bin/update-distribution.sh -r ${repository} -c ${codename}"
    }

    cron { "${title} cron":
      command     => $command,
      user        => $::reprepro::user_name,
      environment => 'SHELL=/bin/bash',
      minute      => '*/5',
      require     => File["${reprepro::homedir}/bin/update-distribution.sh"],
    }
  }
}
