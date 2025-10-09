# @summary
#   Module to manage opensearch.
#
# @param version
#   The version to be installed. See also: https://opensearch.org/downloads.html
#
# @param manage_package
#   Whether to manage the package installation-
# @param package_source
#   The source for the package.
# @param package_ensure
#   The status of the package.
# @param package_architecture
#   The architecture for the package.
# @param package_provider
#   The provider for the package to be used to install the package.
# @param package_directory
#   The directory to install the package. Only used for package_install_method = 'archive'.
# @param pin_package
#   Whether to enable the `apt::pin` or `yum::versionlock` for the package
# @param apt_pin_priority
#   The priority for apt::pin of the opensearch package
#
# @param manage_config
#   Whether to manage the configuration.
# @param use_default_settings
#   Whether to use the modules default settings values.
# @param default_settings
#   The modules default settings for opensearch.
# @param settings
#   Additional settings for opensearch.
# @param use_default_notifications_notifications
#   Whether to use the module default notification settings
# @param notifications_notifications
#   Additional notification settings
# @param use_default_notifications_notifications_core
#   Whether to use the module default notification-core settings
# @param notifications_notifications_core
#   Additional notification-core settings
# @param use_default_observability_observability
#   Whether to use the module default observability settings
# @param observability_observability
#   Additional observability settings
# @param use_default_reporting_reports_scheduler
#   Whether to use the module default reports-scheduler settings
# @param reporting_reports_scheduler
#   Additional reports-scheduler settings
# @param use_default_security_action_groups
#   Whether to use the module default security action_groups settings
# @param security_action_groups
#   Additional security action_groups settings
# @param use_default_security_allowlist
#   Whether to use the module default security allowlist settings
# @param security_allowlist
#   Additional security allowlist settings
# @param use_default_security_audit
#   Whether to use the module default security audit settings
# @param security_audit
#   Additional security audit settings
# @param use_default_security_config
#   Whether to use the module default security config settings
# @param security_config
#   Additional security config settings
# @param use_default_security_internal_users
#   Whether to use the module default security internal_users settings
# @param security_internal_users
#   Additional security internal_users settings
# @param use_default_security_nodes_dn
#   Whether to use the module default security nodes_dn settings
# @param security_nodes_dn
#   Additional security nodes_dn settings
# @param use_default_security_roles_mapping
#   Whether to use the module default security roles_mapping settings
# @param security_roles_mapping
#   Additional security roles_mapping settings
# @param use_default_security_roles
#   Whether to use the module default security roles settings
# @param security_roles
#   Additional security roles settings
# @param use_default_security_tenants
#   Whether to use the module default security tenants settings
# @param security_tenants
#   Additional security tenants settings
# @param use_default_security_whitelist
#   Whether to use the module default security whitelist settings
# @param security_whitelist
#   Additional security whitelist settings
#
# @param heap_size
#   The heap size for the JVM.
#
# @param manage_service
#   Whether to manage the opensearch service.
# @param service_ensure
#   The state for the opensearch service.
# @param service_enable
#   Whether to enable the service.
# @param restart_on_config_change
#   Restart the service on any config changes
# @param restart_on_package_change
#   Restart the service on package changes
#
class opensearch (
  Enum['x64', 'arm64']                      $package_architecture,
  Enum['dpkg', 'rpm']                       $package_provider,
  Hash                                      $default_settings,

  ##
  ## version
  ##
  Optional[String]                          $version                                      = undef,

  ##
  ## package values
  ##
  Boolean                                   $manage_package                               = true,
  Stdlib::Absolutepath                      $package_directory                            = '/opt/opensearch',
  Enum['present', 'absent']                 $package_ensure                               = 'present',
  Enum['archive', 'download', 'repository'] $package_source                               = 'repository',
  Boolean                                   $pin_package                                  = true,
  Integer                                   $apt_pin_priority                             = 1001,

  ##
  ## repository
  ##
  Boolean                                   $manage_repository                            = true,
  Enum['present', 'absent']                 $repository_ensure                            = 'present',
  Optional[Stdlib::HTTPUrl]                 $repository_location                          = undef,
  Stdlib::HTTPUrl                           $repository_gpg_key                           = 'https://artifacts.opensearch.org/publickeys/opensearch.pgp',

  ##
  ## opensearch settings
  ##
  Boolean                                   $manage_config                                = true,
  Boolean                                   $use_default_settings                         = true,
  Hash                                      $settings                                     = {},

  Boolean                                   $use_default_notifications_notifications      = true,
  Hash                                      $notifications_notifications                  = {},

  Boolean                                   $use_default_notifications_notifications_core = true,
  Hash                                      $notifications_notifications_core             = {},

  Boolean                                   $use_default_observability_observability      = true,
  Hash                                      $observability_observability                  = {},

  Boolean                                   $use_default_reporting_reports_scheduler      = true,
  Hash                                      $reporting_reports_scheduler                  = {},

  Boolean                                   $use_default_security_action_groups           = true,
  Hash                                      $security_action_groups                       = {},
  Boolean                                   $use_default_security_allowlist               = true,
  Hash                                      $security_allowlist                           = {},
  Boolean                                   $use_default_security_audit                   = true,
  Hash                                      $security_audit                               = {},
  Boolean                                   $use_default_security_config                  = true,
  Hash                                      $security_config                              = {},
  Boolean                                   $use_default_security_internal_users          = true,
  Hash                                      $security_internal_users                      = {},
  Boolean                                   $use_default_security_nodes_dn                = true,
  Hash                                      $security_nodes_dn                            = {},
  Boolean                                   $use_default_security_roles_mapping           = true,
  Hash                                      $security_roles_mapping                       = {},
  Boolean                                   $use_default_security_roles                   = true,
  Hash                                      $security_roles                               = {},
  Boolean                                   $use_default_security_tenants                 = true,
  Hash                                      $security_tenants                             = {},
  Boolean                                   $use_default_security_whitelist               = true,
  Hash                                      $security_whitelist                           = {},

  ##
  ## java settings
  ##
  Pattern[/\d+[mg]/]                        $heap_size                                    = '512m',

  ##
  ## service values
  ##
  Boolean                                   $manage_service                               = true,
  Stdlib::Ensure::Service                   $service_ensure                               = 'running',
  Boolean                                   $service_enable                               = true,
  Boolean                                   $restart_on_config_change                     = true,
  Boolean                                   $restart_on_package_change                    = true,
) {
  contain opensearch::install
  contain opensearch::config
  contain opensearch::service

  Class['opensearch::install'] -> Class['opensearch::config'] -> Class['opensearch::service']

  if $restart_on_package_change {
    Class['opensearch::install'] ~> Class['opensearch::service']
  }

  if $restart_on_config_change {
    Class['opensearch::config'] ~> Class['opensearch::service']
  }
}
