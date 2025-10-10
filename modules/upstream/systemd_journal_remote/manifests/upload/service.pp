# @summary
#   This class manages the systemd-journal-upload service
#
# @api private
#
class systemd_journal_remote::upload::service (
  Boolean $manage_service                 = $systemd_journal_remote::upload::manage_service,
  Boolean $manage_state                   = $systemd_journal_remote::upload::manage_state,
  Boolean $service_enable                 = $systemd_journal_remote::upload::service_enable,
  Stdlib::Ensure::Service $service_ensure = $systemd_journal_remote::upload::service_ensure,
  String $service_name                    = $systemd_journal_remote::upload::service_name,
) {
  assert_private()

  if $manage_state {
    file { '/var/lib/systemd/journal-upload/state':
      ensure => file,
      owner  => 'systemd-journal-upload',
      group  => 'systemd-journal-upload',
      mode   => '0600',
    }
  }

  if $manage_service {
    service { $service_name:
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
