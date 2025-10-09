# @summary This type creates a cron job via a file in /etc/cron.d
# @param command The command to execute.
# @param ensure The state to ensure this resource exists in. Can be absent, present.
# @param minute The minute the cron job should fire on. Can be any valid cron.
# @param hour The hour the cron job should fire on. Can be any valid cron hour value.
# @param weekday The day of the week the cron job should fire on. Can be any valid cron weekday value.
# @param user The user the cron job should be executed as.
# @param mode The mode to set on the created job file.
# @param environment An array of environment variable settings.
# @param description Optional short description, which will be included in the cron job file.
#
# @example create a weekly cron that runs on the 7th day at 4 am and 1 minute
#  cron::weekly { 'delete_old_temp_files':
#    minute      => '1',
#    hour        => '4',
#    weekday     => '7',
#    environment => [ 'MAILTO="admin@example.com"' ],
#    command     => 'find /tmp -type f -ctime +7 -delete',
#  }
define cron::weekly (
  Optional[String[1]] $command     = undef,
  Cron::Job_ensure    $ensure      = 'present',
  Cron::Minute        $minute      = 0,
  Cron::Hour          $hour        = 0,
  Cron::Weekday       $weekday     = 0,
  Cron::User          $user        = 'root',
  Stdlib::Filemode    $mode        = '0600',
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
