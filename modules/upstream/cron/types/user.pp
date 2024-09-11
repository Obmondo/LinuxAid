# Valid $user parameter to Cron::Job.
type Cron::User = Pattern[/(?i:\A\w[a-z0-9_\.-]{0,30}[a-z0-9_$-]\z)/]
