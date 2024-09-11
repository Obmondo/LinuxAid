# Define: drupal::site
#
# Manage a Drupal site.
#
# === Parameters
#
# [*core_version*]
#   Set the version of the Drupal core to be installed.
#
# [*modules*]
#   Set modules to be installed along with the core (optional). See the README file for examples.
#
# [*themes*]
#   Set themes to be installed along with the core (optional). See the README file for examples.
#
# [*libraries*]
#   Set libraries to be installed (optional). See the README file for examples.
#
# [*settings_content*]
#   Set the content of the `settings.php`.
#
# [*settings_mode*]
#   Set the mode of the `settings.php`.
#
# [*files_path*]
#   Set the relative (!) path of the files directory within the Drupal site. E.g `files` or `sites/default/files`.
#   Should be consistent with the value configured in the ui.
#
# [*files_target*]
#   Set the target of the `files` directory.
#
# [*files_mode*]
#   Set the mode of the `files` directory.
#
# [*files_manage*]
#   Set to `true` to manage the `files` directory of a Drupal site. Set to `false` if the directory is already managed
#   somewhere else.
#
# [*cron_email_address*]
#   The email address to which send reports when the cron run fails.
#
# [*cron_file_path*]
#   Override the default path of the cron file run hourly.
#
# [*cron_file_ensure*]
#   Set the state of the cron file. Either `present` or `absent`.
#
# [*database_updates_disable*]
#   Set to `true` to disable executing pending database updates.
#
# [*makefile_content*]
#   Set content of the makefile to be used (optional). Other parameters used to generate a makefile (`core_version`,
#   `modules` and `themes`) are ignored when this one is used..
#
# [*document_root*]
#   Set the path to the document root. This will result in a symbolic link pointing to a directory containing all
#   modules and themes as configured.
#
# [*process*]
#   Set the name of the process that is executing this Drupal site.
#
# [*timeout*]
#   Set the timeout in seconds of the rebuild site command.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
define drupal::site (
  $core_version             = undef,
  $modules                  = {},
  $themes                   = {},
  $libraries                = {},
  $settings_content         = undef,
  $settings_mode            = undef,
  $files_path               = 'sites/default/files',
  $files_target             = undef,
  $files_mode               = '0644',
  $files_manage             = true,
  $cron_email_address       = undef,
  $cron_file_path           = undef,
  $cron_file_ensure         = present,
  $database_updates_disable = undef,
  $makefile_content         = undef,
  $document_root            = undef,
  $process                  = undef,
  $timeout                  = undef,
) {

  require drupal

  validate_hash($modules)
  validate_hash($themes)
  validate_hash($libraries)
  validate_bool($files_manage)

  $real_document_root = pick($document_root, "${drupal::www_dir}/${title}")
  validate_absolute_path($real_document_root)

  if empty($makefile_content) {
    if $core_version !~ /^[a-zA-Z0-9\._-]+$/ {
      fail("Drupal::Site[${title}]: core_version must be alphanumeric, got '${core_version}'")
    }

    $core_major_version = regsubst($core_version, '(\d+).(\d+)$', '\1', 'I')
    $real_makefile_content = template('drupal/drush.make.erb')
  }
  else {
    $real_makefile_content = $makefile_content
  }

  $makefile_sha1 = sha1($real_makefile_content)
  $config_file = "${drupal::config_dir}/${title}.make"
  $drupal_site_dir = "${drupal::install_dir}/${title}-${makefile_sha1}"

  if empty($files_path) or $files_path =~ /^\/.*$/ {
    fail("Drupal::Site[${title}]: files_path must be a relative path, got '${files_path}'")
  }

  $real_files_path = "${drupal_site_dir}/${files_path}"
  $real_files_target = pick($files_target, "/var/lib/${title}")
  validate_absolute_path($real_files_target)

  $settings_file = "${drupal::config_dir}/${title}.settings.php"
  if empty($settings_content) {
    $real_settings_content = undef
    $real_settings_source = "${drupal_site_dir}/sites/default/default.settings.php"
    $real_settings_replace = false
    $real_settings_mode = pick($settings_mode, '0600')
  }
  else {
    $real_settings_content = $settings_content
    $real_settings_source = undef
    $real_settings_replace = true
    $real_settings_mode = pick($settings_mode, '0400')
  }


  if !empty($process) and $process !~ /^[a-zA-Z0-9\._-]+$/ {
    fail("Drupal::Site[${title}]: process must be alphanumeric, got '${process}'")
  }
  $real_process = pick($process, $drupal::www_process)

  $drush_build_site = "${drupal::drush_path} make --verbose --concurrency=${drupal::drush_concurrency_level} ${config_file} ${drupal_site_dir} >> ${drupal::log_dir}/${title}.log 2>&1"
  $drush_update_database = "${drupal::update_script_path} ${drupal_site_dir} ${title} >> ${drupal::log_dir}/${title}.log 2>&1"
  $drush_check_database_connectivity = "${drupal::drush_path} status bootstrap --field-labels=0 --root=${drupal_site_dir} 2>&1"
  $drush_check_pending_database_updates = "${drupal::drush_path} updatedb-status --pipe --root=${drupal_site_dir} 2>&1"

  $real_database_updates_disable = $database_updates_disable ? {
    # If updates are enabled, the resource noop takes precedence over the global noop settings and hence would be
    # executed during a simulated Puppet run.
    true    => true,
    default => undef,
  }

  $cron_command = "${drupal::drush_path} cron --quiet --root=${real_document_root} --uri=${title}"
  $cron_file_name_sanitized = regsubst("drupal-${title}", '\.', '-', 'G')
  $real_cron_file_path = pick($cron_file_path, "/etc/cron.d/${cron_file_name_sanitized}")
  if $cron_file_ensure !~ /^present|absent$/ {
    fail("Drupal::Site[${title}]: cron_file_ensure must be either present or absent, got '${cron_file_ensure}'")
  }

  file { $config_file:
    ensure  => file,
    content => $real_makefile_content,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
  }

  file { $settings_file:
    ensure  => file,
    content => $real_settings_content,
    source  => $real_settings_source,
    replace => $real_settings_replace,
    owner   => $real_process,
    group   => $real_process,
    mode    => $real_settings_mode,
  }

  exec { "rebuild-drupal-${title}":
    command     => "${drush_build_site} || { rm -rf ${drupal_site_dir}; exit 99; }",
    creates     => $drupal_site_dir,
    environment => "HOME=${::root_home}",
    timeout     => $timeout,
    path        => $drupal::exec_paths,
  }

  file { $real_document_root:
    ensure => link,
    target => $drupal_site_dir,
  }

  if $files_manage {
    file { $real_files_target:
      ensure => directory,
      owner  => $real_process,
      group  => $real_process,
      mode   => $files_mode,
    }
  }

  file { $real_files_path:
    ensure => link,
    target => $real_files_target,
  }

  file { "${drupal_site_dir}/sites/default/settings.php":
    ensure => link,
    target => $settings_file,
  }

  exec { "update-drupal-${title}-database":
    command => $drush_update_database,
    # The command is only executed when all conditions return an exit code 0.
    onlyif  => [
        # Check the site is configured; bootstrap is only emitted when Drupal is fully set up
        "test -n \"`${drush_check_database_connectivity}`\"",

        # Check there are pending updates to be executed; if Drupal is not set up properly, this test will also return
        # true (bootstrap has failed); hence the status safe-guard above.
        "test -n \"`${drush_check_pending_database_updates}`\"" ,
    ],
    user    => $process,
    timeout => $timeout,
    noop    => $real_database_updates_disable,
    path    => $drupal::exec_paths,
  }

  file { $real_cron_file_path:
    ensure  => $cron_file_ensure,
    content => template('drupal/cron.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  #
  # Ensure the order of events
  #

  # first update the Drush makefile
  File[$config_file] ->

  # then rebuild the site (if necessary) ...
  Exec["rebuild-drupal-${title}"] ->

  # then update links to the data directory
  File[$real_files_path] ->

  # then update the settings file
  File[$settings_file] ->

  # and create a link to the settings file
  File["${drupal_site_dir}/sites/default/settings.php"] ->

  # run any outstanding database updates
  Exec["update-drupal-${title}-database"] ->

  # and if everything goes well - update the document root
  File[$real_document_root] ->

  File[$real_cron_file_path]
}
