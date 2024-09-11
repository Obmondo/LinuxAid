# == Class: gerrit
#
# This class is the entry point into installing and configuring a Gerrit
# server
#
# === Parameters
#
# [*db_tag*]
#   The tag to be used by exported database resource records so that a
#   collecting system may easily pick up the database resource
#
# [*download_location*]
#   Base location for downloading the Gerrit war from
#
# [*gerrit_home*]
#   The home directory for the gerrit user / installation path
#
# [*gerrit_site_options*]
#   Override options for installation of the 3 Gerrit site files. The
#   format of this option hash is as follows:
#   gerrit_site_options       => {
#     'GerritSite.css'        => [valid_file_resource_source],
#     'GerritSiteHeader.html' => [valid_file_resource_source],
#     'GerritSiteFooter.html' => [valid_file_resource_source],
#   }
#
#   If an option is not present then the default "blank" file will be
#   used.
#
#   This hash is only used if manage_site_skin is true (default)
#
# [*gerrit_version*]
#   The version of the Gerrit war that will be downloaded
#
# [*install_git*]
#   Should this module make sure that git is installed? (NOTE: a git
#   installation is required for Gerrit to be able to operate. If this
#   is enabled [the default] then a module named ::git will be included
#   puppetlabs/git is the expected module)
#
# [*install_gitweb*]
#   Should this module make sure that gitweb is installed? (NOTE: This
#   will use the system package manager to install gitweb but will do no
#   extra configuration as it will be expected to be managed via gerrit)
#
# [*install_java*]
#   Should this module make sure that a jre is installed? (NOTE: a jre
#   installation is required for Gerrit to operate. If this is enabled
#   [the default] then a module named ::java will be included
#   puppetlabs/java is the expected module)
#
# [*manage_database*]
#   Should the database be managed. The default option of true means
#   that if a mysql or postgresql database are detected in the options
#   then resources will be exported via the
#   puppetlabs/{mysql,postgresql} module API. A db_tag (see above) needs
#   to be set as well so that a system picking up the resource can
#   acquire the appropriate exported resources
#
# [*manage_firewall*]
#   Should the module insert firewall rules for the webUI and SSH?
#   (NOTE: this requires a module compatible with puppetlabs/firewall)
#
# [*manage_site_skin*]
#   Should the Gerrit site theming be managed by the module. If true
#   passing an options hash to gerrit_site_options will override the
#   default "blank" skin files.
#
# [*override_options*]
#   A variable hash for configuration settings of Gerrit. Please see
#   gerrit::params for the default_options hash
#
# [*override_secure_options*]
#   Similar to the override_options hash, this one is used for setting
#   the options in Gerrit's secure.config
#
# [*service_enabled*]
#   Determines if the mode the service is configured for:
#     true: (default) service is ensured started and enabled for reboot
#     false: service is ensured stopped and disabled for reboot
#     manual: service is configured as a manual service, refreshes /
#     notifications will behave per normal when a service is configured
#     with enable => manual. The service is not specifically started or
#     stopped
#
# === Variables
#
# No variables are expressly required to be set, there should be sane
# defaults already configured in gerrit::params which can be overridden
# via hiera
#
# === Examples
#
#  include 'gerrit'
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit (
  $db_tag                   = '',
  $download_location        = $gerrit::params::download_location,
  $gerrit_home              = $gerrit::params::gerrit_home,
  $gerrit_site_options      = {},
  $gerrit_version           = $gerrit::params::gerrit_version,
  $install_git              = $gerrit::params::install_git,
  $install_gitweb           = $gerrit::params::install_gitweb,
  $install_java             = $gerrit::params::install_java,
  $manage_database          = $gerrit::params::manage_database,
  $manage_firewall          = $gerrit::params::manage_firewall,
  $manage_site_skin         = $gerrit::params::manage_site_skin,
  $override_options         = {},
  $override_secure_options  = {},
  $service_enabled          = $gerrit::params::service_enabled
) inherits gerrit::params {

  # Make sure that all of the params are properly formated
  validate_string($db_tag)
  validate_string($download_location)
  validate_absolute_path($gerrit_home)
  validate_hash($gerrit_site_options)
  validate_string($gerrit_version)
  validate_bool($install_git)
  validate_bool($install_java)
  validate_bool($manage_database)
  validate_bool($manage_site_skin)
  validate_hash($override_options)
  validate_hash($override_secure_options)

  unless is_bool($service_enabled) {
    validate_re($service_enabled, '^manual$',
      "${service_enabled} is not supported for service_enabled. \
Allowed values are true, false, 'manual'.")
  }

  # Create a merged together set of options. Rightmost hashes win over left.
  $options = merge($gerrit::params::default_options, $override_options)

  $secure_options = merge($gerrit::params::default_secure_options,
    $override_secure_options)

  anchor { 'gerrit::begin': }
  anchor { 'gerrit::end': }

  include '::gerrit::install'
  include '::gerrit::config'
  include '::gerrit::initialize'
  include '::gerrit::service'

  Anchor['gerrit::begin'] ->
    Class['gerrit::install'] ->
    Class['gerrit::config'] ->
    Class['gerrit::initialize'] ->
    Class['gerrit::service'] ->
  Anchor['gerrit::end']
}
