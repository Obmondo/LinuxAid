# @summary
#   This class manages the systemd-journal-remote service
#
# @api private
#
class systemd_journal_remote::remote::service (
  Boolean $manage_output                  = $systemd_journal_remote::remote::manage_output,
  Boolean $manage_service                 = $systemd_journal_remote::remote::manage_service,
  Boolean $service_enable                 = $systemd_journal_remote::remote::service_enable,
  Stdlib::Ensure::Service $service_ensure = $systemd_journal_remote::remote::service_ensure,
  String $service_name                    = $systemd_journal_remote::remote::service_name,
) {
  assert_private()

  if $manage_output {
    file { '/var/log/journal/':
      ensure => directory,
      owner  => 0,
      group  => 'systemd-journal',
      mode   => '2755',
    }

    file { '/var/log/journal/remote/':
      ensure => directory,
      owner  => 'systemd-journal-remote',
      group  => 'systemd-journal-remote',
      mode   => '2755',
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
