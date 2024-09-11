# == Class: drupal::params
#
# Default configuration values for the `drupal` class.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2016 Martin Meinhold, unless otherwise noted.
#
class drupal::params {
  $install_dir = '/opt/drupal.org'
  $config_dir = '/etc/drush'
  $log_dir = '/var/log/drush'

  $www_dir = '/var/www'
  $www_process = 'www-data'
  
  $exec_paths = [
    '/usr/local/sbin',
    '/usr/local/bin',
    '/usr/sbin',
    '/usr/bin',
    '/sbin',
    '/bin'
  ]
  
  $drush_version = '8.0.5'
  $drush_archive_checksum = 'f6fc333036d8993bd2a834c277e262d200c3075e82c869c213c62ce331f86b77'
  $drush_archive_checksum_type = 'sha256'
  $drush_concurrency_level = 1
  $drush_path = '/usr/local/bin/drush'
  
  $update_script_path = '/usr/local/sbin/drupal-update.sh'
  $update_script_template = 'drupal/drupal-update.sh.erb'
}
