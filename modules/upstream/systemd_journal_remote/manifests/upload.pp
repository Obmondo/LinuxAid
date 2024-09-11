# @summary
#   This class manages and configures the systemd journal upload service
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
#   Manage the journal-upload service
#
# @param manage_state
#   Manage the journal-upload state file creation
#
# @param service_enable
#   Enable the journal-upload service
#
# @param service_ensure
#   Ensure the journal-upload state
#
# @param service_name
#   The journal-upload service name
#
# @param options
#   Config hash to configure the [Upload] options in journal-upload.conf
#
# @author Dan Gibbs <dev@dangibbs.co.uk>
#
class systemd_journal_remote::upload (
  Stdlib::Absolutepath $command_path                        = '/usr/lib/systemd/systemd-journal-upload',
  Systemd_Journal_Remote::Upload_Flags $command_flags       = {},
  Boolean $manage_service                                   = true,
  Boolean $manage_state                                     = false,
  Boolean $service_enable                                   = true,
  Stdlib::Ensure::Service $service_ensure                   = running,
  String $service_name                                      = 'systemd-journal-upload',
  Systemd_Journal_Remote::Upload_Options $options           = {},
) {
  require systemd_journal_remote

  contain systemd_journal_remote::upload::config
  contain systemd_journal_remote::upload::service

  Class['systemd_journal_remote::upload::config']
  -> Class['systemd_journal_remote::upload::service']
}
