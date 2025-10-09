# @summary This type creates a monthly cron job via a file in /etc/cron.d
# @param command The command to execute.
# @param ensure The state to ensure this resource exists in. Can be absent, present.
# @param minute The minute the cron job should fire on. Can be any valid cron value.
# @param hour The hour the cron job should fire on. Can be any valid cron hour value.
# @param date The date the cron job should fire on. Can be any valid cron date value.
# @param environment An array of environment variable settings.
# @param user The user the cron job should be executed as.
# @param mode The mode to set on the created job file.
# @param description Optional short description, which will be included in the cron job file.
#
# @example create a cron job that runs monthly on a 28. day at 7 am and 1 minute
#  cron::monthly { 'delete_old_log_files':
#    minute      => '1',
#    hour        => '7',
#    date        => '28',
#    environment => [ 'MAILTO="admin@example.com"' ],
#    command     => 'find /var/log -type f -ctime +30 -delete',
#  }
define cron::monthly (
  Optional[String[1]] $command     = undef,
  Cron::Job_ensure    $ensure      = 'present',
  Cron::Minute        $minute      = 0,
  Cron::Hour          $hour        = 0,
  Cron::Date          $date        = 1,
  Cron::Environment   $environment = [],
  Cron::User          $user        = 'root',
  Stdlib::Filemode    $mode        = '0600',
  Optional[String]    $description = undef,
) {
  cron::job { $title:
    ensure      => $ensure,
    minute      => $minute,
    hour        => $hour,
    date        => $date,
    month       => '*',
    weekday     => '*',
    user        => $user,
    environment => $environment,
    mode        => $mode,
    command     => $command,
    description => $description,
  }
}
