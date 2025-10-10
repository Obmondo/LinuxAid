# Puppet class for systemd timer drop-in replacement for cron
#
# @param enable Whether to enable the timer. Defaults to true.
#
# @param command The command to run. Defaults to undef.
#
# @param ensure Ensure state of the cron job. Defaults to 'present'.
#
# @param weekday Day of the week for the timer, e.g., '*'. Defaults to '*'.
#
# @param day Day of the month for the timer, e.g., '*'. Defaults to '*'.
#
# @param month Month of the year for the timer, e.g., '*'. Defaults to '*'.
#
# @param year Year for the timer, e.g., '*'. Defaults to '*'.
#
# @param hour Hour of the day for the timer, e.g., '00'. Defaults to '00'.
#
# @param minute Minute of the hour for the timer, e.g., '00'. Defaults to '00'.
#
# @param environment Array of environment variables for the timer. Defaults to [].
#
# @param user User to run the timer as. Defaults to 'root'.
#
# @param mode File mode for the timer files. Defaults to '0644'.
#
# @param description Optional description for the timer.
#
# @param noop_value Optional noop value to disable actual execution. Defaults to undef.
#
define common::systemd::timer (
  Boolean                          $enable      = true,
  Optional[String[1]]              $command     = undef,
  Cron::Job_ensure                 $ensure      = 'present',
  Eit_types::SystemdTimer::Weekday $weekday     = '*',
  Eit_types::SystemdTimer::Day     $day         = '*',
  Eit_types::SystemdTimer::Month   $month       = '*',
  Eit_types::SystemdTimer::Year    $year        = '*',
  Eit_types::SystemdTimer::Hour    $hour        = '00',
  Eit_types::SystemdTimer::Minute  $minute      = '00',
  Cron::Environment                $environment = [],
  Cron::User                       $user        = 'root',
  Stdlib::Filemode                 $mode        = '0644',
  Optional[String]                 $description = undef,
  Optional[Boolean]                $noop_value  = undef,
) {

  Exec {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  $_oncalendar=timeroncalendar($weekday, $year, $month, $day, $hour, $minute)

  $_timer_content = @("EOF")
  # Managed by Puppet. Caveat lector.
  [Timer]
  OnCalendar=${_oncalendar}
  RandomizedDelaySec=30s
  | EOF

  $_service_content = @("EOF")
  # Managed by Puppet. Caveat lector.
  [Service]
  User=${user}
  EnvironmentFile=-/etc/systemd-timer-${title}
  ExecStart=${command}
  | EOF

  if $environment.size > 0 {
    $_environment_content = $environment.join("\n")
    file { "/etc/default/systemd-timer-${title}":
      ensure  => ensure_file($enable),
      content => "${_environment_content}\n",
    }
  }

  systemd::timer { "${title}.timer":
    ensure          => ensure_present($enable),
    enable          => $enable,
    path            => '/etc/systemd/system',
    timer_content   => $_timer_content,
    timer_source    => undef,
    service_content => $_service_content,
    service_source  => undef,
    mode            => $mode,
    service_unit    => undef,
    show_diff       => true,
    active          => $enable,
    notify          => Exec['daemon-reload'],
  }

  cron::job { $title:
    ensure => 'absent',
  }

}
