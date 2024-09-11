type Perforce::Version = Variant[
  Enum['latest'],
  Pattern[/^20[0-9]{2}.[0-9]-[0-9]+$/],
]
