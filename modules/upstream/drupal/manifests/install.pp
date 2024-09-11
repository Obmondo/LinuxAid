# == Class: drupal::install
#
# Install all requirements of the Drupal module.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class drupal::install inherits drupal {

  $drush_download_url = "https://github.com/drush-ops/drush/releases/download/${drupal::drush_version}/drush.phar"

  $drush_filename = "drush-${drupal::drush_version}.phar"
  $drush_install_dir = "${drupal::install_dir}/drush"
  $drush_install_path = "${drush_install_dir}/${drush_filename}"

  file { $drupal::install_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $drupal::config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $drupal::log_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { $drush_install_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  archive::download { $drush_filename:
    ensure           => present,
    url              => $drush_download_url,
    digest_string    => $drupal::drush_archive_checksum,
    digest_type      => $drupal::drush_archive_checksum_type,
    src_target       => $drush_install_dir,
    timeout          => 60,
    follow_redirects => true,
    require          => File[$drupal::install_dir],
  }

  ->

  file { $drush_install_path:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ->

  file { $drupal::drush_path:
    ensure => link,
    target => $drush_install_path,
  }

  file { $drupal::update_script_path:
    ensure  => file,
    content => template($drupal::update_script_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
