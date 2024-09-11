function functions::to_seconds(
  Variant[
    Eit_types::TimeHour,
    Eit_types::TimeMinute,
    Eit_types::DurationSec,
    Eit_types::DurationMillisecond,
    Eit_types::Interval
  ] $amount,
) {
  case $amount {
    Eit_types::DurationMillisecond: {
      $amount / 1000
    }
    Eit_types::DurationSec: {
      $amount
    }
    Eit_types::TimeMinute: {
      $amount * 60
    }
    Eit_types::TimeHour: {
      $amount * 60
    }
    Eit_types::Interval: {
      $_merged_interval = {
        'days'    => 0,
        'hours'   => 0,
        'minutes' => 0,
        'seconds' => 0,
      } + $amount

        (($_merged_interval['days'] * 24 +
          $_merged_interval['hours']) * 60 +
        $_merged_interval['minutes']) * 60 +
        $_merged_interval['seconds']
    }
    default: {
      fail('unknown error')
    }

  }
}
