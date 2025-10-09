# @summary This type creates a cron job via a file in /etc/cron.d
# @param command The command to execute.
# @param ensure The state to ensure this resource exists in. Can be absent, present.
# @param minute The minute the cron job should fire on. Can be any valid cron.
# @param hour The hour the cron job should fire on. Can be any valid cron hour.
# @param date The date the cron job should fire on. Can be any valid cron date.
# @param month The month the cron job should fire on. Can be any valid cron month.
# @param weekday The day of the week the cron job should fire on. Can be any valid cron weekday value.
# @param special A crontab specific keyword like 'reboot'.
# @param environment An array of environment variable settings.
# @param user The user the cron job should be executed as.
# @param group the group the cron job file should by owned by.
# @param mode The mode to set on the created job file.
# @param description Optional short description, which will be included in the cron job file.
#
# @example create a cron job
#  cron::job { 'generate_puppetdoc':
#    minute      => '01',
#    environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
#    command     => 'puppet doc /etc/puppet/modules >/var/www/puppet_docs.mkd',
#  }
define cron::job (
  Optional[String[1]] $command     = undef,
  Cron::Job_ensure    $ensure      = 'present',
  Cron::Minute        $minute      = '*',
  Cron::Hour          $hour        = '*',
  Cron::Date          $date        = '*',
  Cron::Month         $month       = '*',
  Cron::Weekday       $weekday     = '*',
  Cron::Special       $special     = undef,
  Cron::Environment   $environment = [],
  Cron::User          $user        = 'root',
  Variant[String[1],Integer[0]] $group = 0,
  Stdlib::Filemode    $mode        = '0600',
  Optional[String]    $description = undef,
) {
  assert_type(Cron::Jobname, $title)

  case $ensure {
    'absent':  {
      file { "job_${title}":
        ensure => 'absent',
        path   => "/etc/cron.d/${title}",
      }
    }
    default: {
      file { "job_${title}":
        ensure  => 'file',
        owner   => 'root',
        group   => $group,
        mode    => $mode,
        path    => "/etc/cron.d/${title}",
        content => epp('cron/job.epp', {
            name        => $name,
            environment => $environment,
            description => $description,
            special     => $special,
            user        => $user,
            command     => $command,
            minute      => $minute,
            hour        => $hour,
            date        => $date,
            month       => $month,
            weekday     => $weekday,
        }),
      }
    }
  }
}
