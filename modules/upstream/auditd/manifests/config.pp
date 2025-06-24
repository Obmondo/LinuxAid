# NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# @summary This class is called from auditd for service config.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config {
  assert_private()

  if $auditd::default_audit_profile != undef {
    deprecation('auditd::default_audit_profile',
      "'auditd::default_audit_profile' is deprecated. Use 'auditd::default_audit_profiles' instead")
    if $auditd::default_audit_profile {
      $profiles = [ 'simp' ]
    } else {
      $profiles = []
    }
  } else {
    $profiles = $auditd::default_audit_profiles
  }

  $config_file_mode = $auditd::log_group ? {
    'root'  => '0600',
    default => '0640'
  }

  $log_file_mode = $auditd::log_group ? {
    'root'  => 'u+rX,g-rwx,o-rwx',
    default => 'u+rX,g+rX,g-w,o-rwx'
  }

  file { '/etc/audit':
    ensure  => 'directory',
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $config_file_mode,
    recurse => true,
    purge   => true
  }

  file { '/etc/audit/rules.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $config_file_mode,
    recurse => true,
    purge   => $auditd::purge_auditd_rules
  }

  file { [
    '/etc/audit/audit.rules',
    '/etc/audit/audit.rules.prev'
  ]:
    owner => 'root',
    group => $auditd::log_group,
    mode  => 'o-rwx'
  }

  # Build the auditd.conf from parts

  $_auditd_conf_common = epp("${module_name}/etc/audit/auditd.conf.epp")

  if $facts['auditd_version'] {
    if (versioncmp($facts['auditd_version'], '3.0') < 0) {
      $_auditd_conf_main = epp("${module_name}/etc/audit/auditd.2.conf.epp")
    } else  {
      $_auditd_conf_main = epp("${module_name}/etc/audit/auditd.3.conf.epp")
    }
  } else {
    # If auditd version is unknown use 'best guess' at default OS version
    $_auditd_conf_main = $facts['os']['release']['major'] < '8' ? {
      false   => epp("${module_name}/etc/audit/auditd.3.conf.epp"),
      default => epp("${module_name}/etc/audit/auditd.2.conf.epp")
    }
  }

  $_auditd_conf_last = epp("${module_name}/etc/audit/auditd.last.conf.epp")

  file { '/etc/audit/auditd.conf':
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $config_file_mode,
    content => "${_auditd_conf_common}${_auditd_conf_main}${_auditd_conf_last}\n",
    notify  => Class['auditd::service']
  }

  if defined('$auditd::plugin_dir') {
    file { $auditd::plugin_dir:
      ensure => 'directory',
      owner  => 'root',
      group  => $auditd::log_group,
      mode   => '0750'
    }
  }

  file { '/var/log/audit':
    ensure  => 'directory',
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $log_file_mode,
    recurse => true
  }

  if $auditd::syslog {
    include 'auditd::config::logging'
    Class['auditd::config::logging'] ~> Class['auditd::service']
  }

  unless empty($profiles) {
    # use contain instead of include so that config file changes can
    # notify auditd::service class
    contain 'auditd::config::audit_profiles'
  }
}
