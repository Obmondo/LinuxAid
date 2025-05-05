# Piwik Install class
class piwik::install (
  Stdlib::Absolutepath $path,
  $user,
  $version,
  $source_repo,
  $source_repo_provider,
  String $geoip_package,
  Stdlib::Absolutepath $geoip_city_path,
) {

  stdlib::ensure_packages(['git', 'composer'])

  file { '/var/www':
    ensure => 'directory',
    group  => $user,
    mode   => '0775',
  }

  vcsrepo { $path:
    ensure   => present,
    provider => $source_repo_provider,
    source   => $source_repo,
    user     => $user,
    require  => File['/var/www'],
    notify   => Exec['install piwik dependencies'],
  }

  file { $path:
    owner   => $user,
    group   => $user,
    require => Vcsrepo[$path],
    notify  => Exec['install piwik dependencies'],
    mode    => '0755'
  }

  exec { 'install piwik dependencies':
    cwd         => $path,
    command     => 'composer install',
    path        => ['/usr/bin'],
    environment => ['HOME=/var/www'],
    user        => $user,
    refreshonly => true,
  }

  package { $geoip_package:
    ensure => present,
  }

  file { "${path}/misc/GeoIPCity.dat":
    ensure  => link,
    target  => $geoip_city_path,
    require => Package[$geoip_package],
  }

}
