# Common logging class
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
