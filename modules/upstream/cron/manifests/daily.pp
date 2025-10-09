# @summary This type creates a daily cron job via a file in /etc/cron.d
# @param command The command to execute.
# @param ensure The state to ensure this resource exists in. Can be absent, present.
# @param minute  The minute the cron job should fire on. Can be any valid cron.
# @param hour The hour the cron job should fire on. Can be any valid cron hour value.
# @param environment An array of environment variable settings.
# @param user The user the cron job should be executed as.
# @param mode The mode to set on the created job file.
# @param description Optional short description, which will be included in the cron job file.
#
# @example create a daily cron job with custom PATH environment variable
#  cron::daily { 'mysql_backup':
#    minute      => '1',
#    hour        => '3',
#    environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
#    command     => 'mysqldump -u root my_db >/backups/my_db.sql',
#  }
define cron::daily (
  Optional[String[1]] $command     = undef,
  Cron::Job_ensure    $ensure      = 'present',
  Cron::Minute        $minute      = 0,
  Cron::Hour          $hour        = 0,
  Cron::Environment   $environment = [],
  Cron::User          $user        = 'root',
  Stdlib::Filemode    $mode        = '0600',
  Optional[String]    $description = undef,
) {
  cron::job { $title:
    ensure      => $ensure,
    minute      => $minute,
    hour        => $hour,
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => $user,
    environment => $environment,
    mode        => $mode,
    command     => $command,
    description => $description,
  }
}
