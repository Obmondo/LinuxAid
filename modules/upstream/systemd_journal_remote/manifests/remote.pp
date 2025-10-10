# @summary
#   This module manages and configures the systemd journal remote package
#
# @api public
#
# @param command_path
#   The service ExecStart command path
#
# @param command_flags
#   The service ExecStart command flags to use
#
# @param manage_output
#   Manage the creation of the default output paths (/var/log/journal/remote/)
#
# @param manage_service
#   Manage the `systemd-journal-remote` service
#
# @param service_enable
#   Enable the journal-remote service
#
# @param service_ensure
#   Ensure the journal-remote service state
#
# @param service_name
#   The journal-remote service name
#
# @param options
#   Config hash to configure the [Remote] options in `journal-remote.conf`
#
# @author Dan Gibbs <dev@dangibbs.co.uk>
#
class systemd_journal_remote::remote (
  Stdlib::Absolutepath $command_path                        = '/usr/lib/systemd/systemd-journal-remote',
  Systemd_Journal_Remote::Remote_Flags $command_flags       = {},
  Boolean $manage_output                                    = false,
  Boolean $manage_service                                   = true,
  Boolean $service_enable                                   = true,
  Stdlib::Ensure::Service $service_ensure                   = running,
  String $service_name                                      = 'systemd-journal-remote',
  Systemd_Journal_Remote::Remote_Options $options           = {},
) {
  require systemd_journal_remote

  contain systemd_journal_remote::remote::config
  contain systemd_journal_remote::remote::service

  Class['systemd_journal_remote::remote::config']
  -> Class['systemd_journal_remote::remote::service']
}
