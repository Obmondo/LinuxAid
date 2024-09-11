# Type: cron::weekly
#
# This type creates a cron job via a file in /etc/cron.d
#
# Parameters:
#   ensure - The state to ensure this resource exists in. Can be absent, present
#     Defaults to 'present'
#   minute - The minute the cron job should fire on. Can be any valid cron
#   minute value.
#     Defaults to '0'.
#   hour - The hour the cron job should fire on. Can be any valid cron hour
#   value.
#     Defaults to '0'.
#   weekday - The day of the week the cron job should fire on. Can be any valid
#   cron weekday value.
#     Defaults to '0'.
#   environment - An array of environment variable settings.
#     Defaults to an empty set ([]).
#   user - The user the cron job should be executed as.
#     Defaults to 'root'.
#   mode - The mode to set on the created job file
#     Defaults to '0640'.
#   description - Optional short description, which will be included in the
#   cron job file.
#     Defaults to undef.
#   command - The command to execute.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#   cron::weekly { 'delete_old_temp_files':
#     minute      => '1',
#     hour        => '4',
#     weekday     => '7',
#     environment => [ 'MAILTO="admin@example.com"' ],
#     command     => 'find /tmp -type f -ctime +7 -delete',
#   }
#
define cron::weekly (
  Optional[String[1]] $command     = undef,
  Cron::Job_ensure    $ensure      = 'present',
  Cron::Minute        $minute      = 0,
  Cron::Hour          $hour        = 0,
  Cron::Weekday       $weekday     = 0,
  Cron::User          $user        = 'root',
  Cron::Mode          $mode        = '0644',
  Cron::Environment   $environment = [],
  Optional[String]    $description = undef,
) {

  cron::job { $title:
    ensure      => $ensure,
    minute      => $minute,
    hour        => $hour,
    date        => '*',
    month       => '*',
    weekday     => $weekday,
    user        => $user,
    environment => $environment,
    mode        => $mode,
    command     => $command,
    description => $description,
  }

}

