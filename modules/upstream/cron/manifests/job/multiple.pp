# @summary This type creates multiple cron jobs via a single file in /etc/cron.d/
# @param jobs A hash of multiple cron jobs using the same structure as cron::job and using the same defaults for each parameter.
# @param ensure The state to ensure this resource exists in. Can be absent, present.
# @param environment An array of environment variable settings.
# @param mode The mode to set on the created job file.
#
# @example create multiple cron jobs at once
#  cron::job::multiple { 'test':
#    jobs => [
#      {
#        minute      => '55',
#        hour        => '5',
#        date        => '*',
#        month       => '*',
#        weekday     => '*',
#        user        => 'rmueller',
#        command     => '/usr/bin/uname',
#      },
#      {
#        command     => '/usr/bin/sleep 1',
#      },
#      {
#        command     => '/usr/bin/sleep 10',
#        special     => 'reboot',
#      },
#    ],
#    environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
#  }
define cron::job::multiple (
  Array[Struct[{
        Optional['command']     => String[1],
        Optional['minute']      => Cron::Minute,
        Optional['hour']        => Cron::Hour,
        Optional['date']        => Cron::Date,
        Optional['month']       => Cron::Month,
        Optional['weekday']     => Cron::Weekday,
        Optional['special']     => Cron::Special,
        Optional['user']        => Cron::User,
        Optional['description'] => String,
  }]]               $jobs,
  Cron::Job_ensure  $ensure      = 'present',
  Cron::Environment $environment = [],
  Stdlib::Filemode  $mode        = '0600',
) {
  case $ensure {
    'absent': {
      file { "job_${title}":
        ensure => absent,
        path   => "/etc/cron.d/${title}",
      }
    }
    default:  {
      file { "job_${title}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => $mode,
        path    => "/etc/cron.d/${title}",
        content => epp('cron/multiple.epp', {
            name        => $name,
            environment => $environment,
            jobs        => $jobs,
        }),
      }
    }
  }
}
