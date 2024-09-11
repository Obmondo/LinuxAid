# Valid $weekday parameter to SystemdTimer::Weekday.
type Eit_types::SystemdTimer::Weekday = Variant[
  Enum['*', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  Array[Enum['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']]
]
