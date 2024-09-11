# Valid $weekday parameter to Cron::Job.
type Cron::Weekday = Variant[
  Cron::Weekdayname,
  Integer[0,7],
  Pattern[/(?x)\A(
    \* ( \/ [1-7] )?
    |       [0-7] ( - [0-7] ( \/ [1-7] )? )?
        ( , [0-7] ( - [0-7] ( \/ [1-7] )? )? )*
  )\z/]
]
