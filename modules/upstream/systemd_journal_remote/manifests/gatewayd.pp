# @summary
#   This class manages and configures the `systemd-journal-gatewayd` service
#
# @api public
#
# @param command_path
#   The service ExecStart command path
#
# @param command_flags
#   The service ExecStart command flags to use
#
# @param manage_service
#   Manage the journal-gatewayd service
#
# @param service_enable
#   Enable the journal-gatewayd service
#
# @param service_ensure
#   The journal-gatewayd service ensure state
#
# @param service_name
#   The journal-gatewayd service name
#
# @author Dan Gibbs <dev@dangibbs.co.uk>
#
class systemd_journal_remote::gatewayd (
  Stdlib::Absolutepath $command_path                        = '/usr/lib/systemd/systemd-journal-gatewayd',
  Systemd_Journal_Remote::Gatewayd_Flags $command_flags     = {},
  Boolean $manage_service                                   = true,
  Boolean $service_enable                                   = true,
  Stdlib::Ensure::Service $service_ensure                   = running,
  String $service_name                                      = 'systemd-journal-gatewayd',
) {
  require systemd_journal_remote

  contain systemd_journal_remote::gatewayd::config
  contain systemd_journal_remote::gatewayd::service

  Class['systemd_journal_remote::gatewayd::config']
  -> Class['systemd_journal_remote::gatewayd::service']
}
