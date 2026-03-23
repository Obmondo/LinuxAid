# Logging
class profile::logging (
  Boolean          $manage        = $::common::logging::manage,
  Eit_types::Group $log_dir_group = $::common::logging::log_dir_group,
  Stdlib::Filemode $log_dir_mode  = $::common::logging::log_dir_mode,
) {

  if $manage {
    # Ensure the configured logging group exists before it is used by file resources.
    ensure_resource('group', $log_dir_group, {
      ensure => present,
      system => true,
    })

    # On Debian/Ubuntu the rsyslog daemon runs as the `syslog` user/group, but
    # this user doesn't have write access to /var/log by default.
    file { '/var/log':
      ensure => directory,
      group  => $log_dir_group,
      mode   => $log_dir_mode,
      require => Group[$log_dir_group],
    }

    # RHEL systems needs to have /var/log/rhsm, otherwise logs are output on
    # stderr: https://bugzilla.redhat.com/show_bug.cgi?id=1686920
    if $facts['os']['name'] == 'RedHat' {
      file { '/var/log/rhsm':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => 'a=rx,u+w',
      }
    }
  }

}
