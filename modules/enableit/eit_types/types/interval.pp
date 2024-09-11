# Plugin Notification
type Eit_types::Interval = Struct[{
  'days'    => Optional[Integer[0,default]],
  'hours'   => Optional[Eit_types::TimeHour],
  'minutes' => Optional[Eit_types::TimeMinute],
  'seconds' => Optional[Eit_types::TimeSecond],
}]
