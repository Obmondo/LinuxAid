# @summary
#   This class manages the systemd-journal-gatewayd service
#
# @api private
#
class systemd_journal_remote::gatewayd::service (
  Boolean $manage_service                 = $systemd_journal_remote::gatewayd::manage_service,
  Boolean $service_enable                 = $systemd_journal_remote::gatewayd::service_enable,
  Stdlib::Ensure::Service $service_ensure = $systemd_journal_remote::gatewayd::service_ensure,
  String $service_name                    = $systemd_journal_remote::gatewayd::service_name,
) {
  assert_private()

  if $manage_service {
    service { $service_name:
      ensure => $service_ensure,
      name   => $service_name,
      enable => $service_enable,
    }
  }
}
