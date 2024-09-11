# Type: cron::job::multiple
#
# This type creates multiple cron jobs via a single file in /etc/cron.d/
#
# Parameters:
#   jobs - required - a hash of multiple cron jobs using the same structure as
#     cron::job and using the same defaults for each parameter.
#   ensure - The state to ensure this resource exists in. Can be absent, present
#     Defaults to 'present'
#   environment - An array of environment variable settings.
#     Defaults to an empty set ([]).
#   mode - The mode to set on the created job file
#     Defaults to 0644.
#
# Sample Usage:
#
# cron::job::multiple { 'test':
#   jobs => [
#     {
#       minute      => '55',
#       hour        => '5',
#       date        => '*',
#       month       => '*',
#       weekday     => '*',
#       user        => 'rmueller',
#       command     => '/usr/bin/uname',
#     },
#     {
#       command     => '/usr/bin/sleep 1',
#     },
#     {
#       command     => '/usr/bin/sleep 10',
#       special     => 'reboot',
#     },
#   ],
#   environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
# }
# 
# This will generate those three cron jobs in `/etc/cron.d/test`:
# 55 5 * * *  rmueller  /usr/bin/uname
# * * * * *  root  /usr/bin/sleep 1
# @reboot root /usr/bin/sleep 10
#
define cron::job::multiple(
  Array[Struct[{
    Optional['command']     => String[1],
    Optional['minute']      => Cron::Minute,
    Optional['hour']        => Cron::Hour,
    Optional['date']        => Cron::Date,
    Optional['month']       => Cron::Month,
    Optional['weekday']     => Cron::Weekday,
    Optional['special']     => Cron::Special,
    Optional['environment'] => Cron::Environment,
    Optional['user']        => Cron::User,
    Optional['description'] => String,
  }]]               $jobs,
  Cron::Job_ensure  $ensure      = 'present',
  Cron::Environment $environment = [],
  Cron::Mode        $mode        = '0644',
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
        content => template('cron/multiple.erb'),
      }
    }
  }
}
