type Profile::Cron::Hour = Variant[
  Enum['*'],
  Integer[0,24],
  Array[Integer[0,24]],
  Pattern[/^\*\/[0-9]+$/],
  Pattern[/^[0-9]+-[0-9]+$/]]
