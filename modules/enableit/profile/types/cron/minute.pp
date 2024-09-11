type Profile::Cron::Minute = Variant[
  Enum['*'],
  Integer[0,60],
  Array[Integer[0,60]],
  Pattern[/^\*\/[0-9]+$/],
  Pattern[/^[0-9]+-[0-9]+$/]]
