# Valid $month parameter to Cron::Job.
type Cron::Month = Variant[
  Cron::Monthname,
  Integer[1,12],
  Pattern[/(?x)\A(
    \* ( \/ ( 1[012]?|[2-9] ) )?
    |       ( 1[012]?|[2-9] ) ( - ( 1[012]?|[2-9] ) ( \/ ( 1[012]?|[2-9] ) )? )?
        ( , ( 1[012]?|[2-9] ) ( - ( 1[012]?|[2-9] ) ( \/ ( 1[012]?|[2-9] ) )? )? )*
  )\z/]
]
