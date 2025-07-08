# @summary Class for managing common logging configuration
#
# @param manage 
# Whether to manage logging components. Defaults to true.
#
# @param log_dir_group Optional group for log directory permissions.
#
# @param log_dir_mode Mode for the log directory. Defaults to '0755'.
#
class common::logging (
  Boolean                    $manage        = true,
  Optional[Eit_types::Group] $log_dir_group = undef,
  Stdlib::Filemode           $log_dir_mode  = '0755',
) {
  if $manage {
    if lookup('common::logging::logrotate::manage', Boolean, undef, false) {
      contain ::common::logging::logrotate
    }
    if lookup('common::logging::rsyslog::manage', Boolean, undef, false) {
      contain ::common::logging::rsyslog
    }
    if lookup('common::logging::journal::manage', Boolean, undef, false) {
      contain ::common::logging::journal
    }
    contain ::profile::logging
  }
}
