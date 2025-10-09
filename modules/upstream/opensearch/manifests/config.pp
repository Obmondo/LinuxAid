# @summary
#   Configure opensearch.
#
# @api private
#
class opensearch::config {
  assert_private()

  if $opensearch::manage_config {
    $config_directory = $opensearch::package_source ? {
      'archive' => "${opensearch::package_directory}/config",
      default   => '/etc/opensearch',
    }

    $settings = $opensearch::use_default_settings ? {
      true  => $opensearch::default_settings + $opensearch::settings,
      false => $opensearch::settings,
    }

    $notifications_notifications = $opensearch::use_default_notifications_notifications ? {
      true  => lookup('opensearch::default_notifications_notifications', Hash) + $opensearch::notifications_notifications,
      false => $opensearch::notifications_notifications,
    }

    $notifications_notifications_core = $opensearch::use_default_notifications_notifications_core ? {
      true  => lookup('opensearch::default_notifications_notifications_core', Hash) + $opensearch::notifications_notifications_core,
      false => $opensearch::notifications_notifications_core,
    }

    $observability_observability = $opensearch::use_default_observability_observability ? {
      true  => lookup('opensearch::default_observability_observability', Hash) + $opensearch::observability_observability,
      false => $opensearch::observability_observability,
    }

    $reporting_reports_scheduler = $opensearch::use_default_reporting_reports_scheduler ? {
      true  => lookup('opensearch::default_reporting_reports_scheduler', Hash) + $opensearch::reporting_reports_scheduler,
      false => $opensearch::reporting_reports_scheduler,
    }

    $security_action_groups = $opensearch::use_default_security_action_groups ? {
      true  => lookup('opensearch::default_security_action_groups', Hash) + $opensearch::security_action_groups,
      false => $opensearch::security_action_groups,
    }

    $security_allowlist = $opensearch::use_default_security_allowlist ? {
      true  => lookup('opensearch::default_security_allowlist', Hash) + $opensearch::security_allowlist,
      false => $opensearch::security_allowlist,
    }

    $security_audit = $opensearch::use_default_security_audit ? {
      true  => lookup('opensearch::default_security_audit', Hash) + $opensearch::security_audit,
      false => $opensearch::security_audit,
    }

    $security_config = $opensearch::use_default_security_config ? {
      true  => lookup('opensearch::default_security_config', Hash) + $opensearch::security_config,
      false => $opensearch::security_config,
    }

    $security_internal_users = $opensearch::use_default_security_internal_users ? {
      true  => lookup('opensearch::default_security_internal_users', Hash) + $opensearch::security_internal_users,
      false => $opensearch::security_internal_users,
    }

    $security_nodes_dn = $opensearch::use_default_security_nodes_dn ? {
      true  => lookup('opensearch::default_security_nodes_dn', Hash) + $opensearch::security_nodes_dn,
      false => $opensearch::security_nodes_dn,
    }

    $security_roles_mapping = $opensearch::use_default_security_roles_mapping ? {
      true  => lookup('opensearch::default_security_roles_mapping', Hash) + $opensearch::security_roles_mapping,
      false => $opensearch::security_roles_mapping,
    }

    $security_roles = $opensearch::use_default_security_roles ? {
      true  => lookup('opensearch::default_security_roles', Hash) + $opensearch::security_roles,
      false => $opensearch::security_roles,
    }

    $security_tenants = $opensearch::use_default_security_tenants ? {
      true  => lookup('opensearch::default_security_tenants', Hash) + $opensearch::security_tenants,
      false => $opensearch::security_tenants,
    }

    $security_whitelist = $opensearch::use_default_security_whitelist ? {
      true  => lookup('opensearch::default_security_whitelist', Hash) + $opensearch::security_whitelist,
      false => $opensearch::security_whitelist,
    }

    file { "${config_directory}/opensearch.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $settings.stdlib::to_yaml,
    }

    file { "${config_directory}/jvm.options":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => epp("${module_name}/jvm.options.epp"),
    }

    file { "${config_directory}/opensearch-notifications/notifications.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $notifications_notifications.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-notifications-core/notifications-core.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $notifications_notifications_core.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-reports-scheduler/reports-scheduler.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $reporting_reports_scheduler.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/action_groups.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_action_groups.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/allowlist.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_allowlist.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/audit.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_audit.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/config.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_config.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/internal_users.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_internal_users.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/nodes_dn.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_nodes_dn.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/roles_mapping.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_roles_mapping.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/roles.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_roles.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/tenants.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_tenants.stdlib::to_yaml,
    }

    file { "${config_directory}/opensearch-security/whitelist.yml":
      ensure  => file,
      owner   => 'opensearch',
      group   => 'opensearch',
      mode    => '0640',
      content => $security_whitelist.stdlib::to_yaml,
    }
  }
}
