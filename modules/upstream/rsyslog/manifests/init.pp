# @summary
#   Manage the Rsyslog daemon package, service, and
#   configuration.
#
# @author Vox Pupuli <voxpupuli@groups.io>
#
# @example using class
#   class { 'rsyslog':
#     manage_service => true,
#   }
#
# @example using hieradata
#   # Manifest
#   include rsyslog
#   include rsyslog::config
#
#   # Hieradata
#   ---
#   rsyslog::confdir: /etc/rsyslog.d
#   rsyslog::package_name: rsyslog
#   rsyslog::config::global_config:
#     workDirectory:
#       value: '/var/spool/rsyslog'
#
# @param confdir
#   The rsyslog configuration directory.
# @param package_name
#   The name of the rsyslog package to install.
# @param package_version
#   The version of rsyslog to install.
# @param config_file
#   The global rsyslog configuration file.
# @param feature_packages
#   List of additional rsyslog packages to install.
# @param module_load_priority
#   Order the loading of rsyslog modules relative to other configuration.
# @param service_name
#   Name of the SystemD, Upstart, or SysVInit service.
# @param service_status
#   State desired for the rsyslog service.
# @param service_enabled
#   Is the service enabled or not.
# @param override_default_config
#   Override the default rsyslog.conf file.
# @param manage_package
#   Toggle the managing of the rsyslog package.
# @param use_upstream_repo
#   Toggle using the upstream Adiscon Rsyslog repository.
# @param manage_confdir
#   Toggle management of the Rsyslog configuration directory.
# @param manage_service
#   Toggle management of the rsyslog service.
# @param external_service
#   Toggle if the service is external to where rsyslog is being run.
#   I.E. a service that starts a docker container running rsyslog.
# @param purge_config_files
#   Toggle purging of unmanaged configuration files.
# @param global_config_priority
#   Set the global ordering of global configuration parameters in rsyslog.
# @param legacy_config_priority
#   Set the global ordering of legacy configuration parameters in rsyslog.
# @param template_priority
#   Set the global ordering of template configuration in rsyslog.
# @param action_priority
#   Set the global ordering of action configuration in rsyslog.
# @param input_priority
#   Set the global ordering of input configuration in rsyslog.
# @param custom_priority
#   Set the global ordering of custom configuration in rsyslog.
# @param main_queue_priority
#   Set the global ordering of main queue configuration in rsyslog.
# @param lookup_table_priority
#   Set the global ordering of lookup table configuration in rsyslog.
# @param parser_priorty
#   Set the global ordering of parser configuration in rsyslog.
# @param ruleset_priority
#   Set the global ordering of rulesets configuration in rsyslog.
# @param filter_priority
#   Set the global ordering of filter configuration in rsyslog.
# @param target_file
#   Target file to insert configuration into.
# @param conf_permissions
#   Set the file mode for the generated configuration files.
# @param confdir_permissions
#   Set the file mode for the rsyslog.d configuration directory.
# @param global_conf_perms
#   Set the file mode for the /etc/rsyslog.conf
#
class rsyslog (
  String            $confdir,
  String            $package_name,
  String            $package_version,
  String            $config_file,
  Array             $feature_packages,
  Integer           $module_load_priority,
  String            $service_name,
  String            $service_status,
  Boolean           $service_enabled,
  Boolean           $override_default_config,
  Boolean           $manage_package,
  Boolean           $use_upstream_repo,
  Boolean           $manage_confdir,
  Boolean           $manage_service,
  Boolean           $external_service,
  Boolean           $purge_config_files,
  Integer           $global_config_priority,
  Integer           $legacy_config_priority,
  Integer           $template_priority,
  Integer           $action_priority,
  Integer           $input_priority,
  Integer           $custom_priority,
  Integer           $main_queue_priority,
  Integer           $lookup_table_priority,
  Integer           $parser_priority,
  Integer           $ruleset_priority,
  Integer           $filter_priority,
  String            $target_file,
  Stdlib::Filemode  $conf_permissions = '0644',
  Stdlib::Filemode  $confdir_permissions = '0755',
  Stdlib::Filemode  $global_conf_perms = $conf_permissions,
) {
  if $manage_service == true and $external_service == true {
    fail('manage_service and external_service cannot be set at the same time!')
  } else {
    contain 'rsyslog::base'
  }
}
