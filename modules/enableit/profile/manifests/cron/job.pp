# Wrapper that escapes cron command for easy use
define profile::cron::job (
  String                                        $command,
  Boolean                                       $enable      = true,
  Eit_types::User                               $user        = 'root',
  Variant[Enum['*'], Eit_types::Time::Weekdays] $weekday     = '*',
  Cron::Month                                   $month       = '*',
  Variant[Enum['*'], Eit_types::Time::Monthday] $monthday    = '*',
  Profile::Cron::Hour                           $hour        = '*',
  Profile::Cron::Minute                         $minute      = '*',
  Hash[String, String]                          $environment = {},
  Eit_types::Noop_Value                         $noop_value  = undef,
) {

  $_weekdays_lookup = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
  $_weekdays = pick(*[
    if $weekday =~ Array {
      $weekday.map |$_day| {
        $_weekdays_lookup.index($_day) + 1
      }
    },
    $weekday,
  ])

  cron { $title:
    # Ensure that we escape all `%`; they are translated into newlines in
    # regular cron
    ensure      => ensure_present($enable),
    command     => $command.regsubst(/%/, '\\%', 'G'),
    user        => $user,
    weekday     => $_weekdays,
    month       => $month,
    monthday    => $monthday,
    hour        => $hour,
    minute      => $minute,
    environment => if Boolean($environment.count) {
      $environment.map |$k, $v| {
        "${k}=${v}"
      }.join(' ')
    },
    noop        => $noop_value,
  }
}
