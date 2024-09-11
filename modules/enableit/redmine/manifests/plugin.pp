#= Type redmine::plugin
#== Parameters
#
#[*ensure*]
#  Wether the plugin should be installed.
#  Possible values are installed, latest, and absent.
#
#[*source*]
#  Repository of the plugin. Required
#
#[*version*]
#  Set to desired version.
#
#[*provider*]
#  The vcs provider. Default: git
#
define redmine::plugin (
  $ensure   = present,
  $source   = undef,
  $version  = undef,
  $provider = 'git',
) {

  $install_dir = "${redmine::install_dir}/plugins/${name}"
  if $ensure == absent {
    exec { "rake redmine:plugins:migrate NAME=${name} VERSION=0":
      notify      => Class['apache::service'],
      path        => ['/bin','/usr/bin', '/usr/local/bin'],
      environment => ['HOME=/root','RAILS_ENV=production','REDMINE_LANG=en'],
      provider    => 'shell',
      cwd         => $redmine::install_dir,
      before      => Vcsrepo[$install_dir],
      require     => Exec['bundle_update'],
      onlyif      => "test -d ${install_dir}",
    }
    $notify = undef
  } else {
    $notify = Exec['bundle_update']
  }

  if $source == undef {
    fail("no source specified for redmine plugin '${name}'")
  }
  validate_string($source)

  case $provider {
    'svn' : {
      $provider_package = 'subversion'
    }
    'hg': {
      $provider_package = 'mercurial'
    }
    default: {
      $provider_package = $provider
    }
  }
  ensure_packages($provider_package)

  vcsrepo { $install_dir:
    ensure   => $ensure,
    revision => $version,
    source   => $source,
    provider => $provider,
    notify   => $notify,
    require  => [ Package[$provider_package]
                , Exec['bundle_redmine'] ]
  }
}
