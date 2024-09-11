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

  $log_file_mode = $auditd::log_group ? {
    'root'  => '0600',
    default => '0640',
  }

  file { '/etc/audit':
    ensure  => 'directory',
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $log_file_mode,
    recurse => true,
    purge   => true
  }

  file { '/etc/audit/rules.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => $auditd::log_group,
    mode    => $log_file_mode,
    recurse => true,
    purge   => true
  }

  file { '/etc/audit/audit.rules':
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
    mode    => $log_file_mode,
    content => "${_auditd_conf_common}${_auditd_conf_main}${_auditd_conf_last}\n",
    notify  => Service['auditd']
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
    ensure => 'directory',
    owner  => 'root',
    group  => $auditd::log_group,
    mode   => 'o-rwx'
  }

  file { $auditd::log_file:
    owner => 'root',
    group => $auditd::log_group,
    mode  => $log_file_mode
  }

  if ($facts['os']['release']['major'] < '7') {
    # make sure audit.rules is regenerated every time the
    # service is started
    augeas { 'auditd/USE_AUGENRULES':
      changes => [
        'set /files/etc/sysconfig/auditd/USE_AUGENRULES yes',
      ],
    }
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
