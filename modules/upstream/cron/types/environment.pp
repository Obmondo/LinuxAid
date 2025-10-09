# Valid $environment parameter to Cron::Job.
type Cron::Environment = Array[Variant[Pattern[/(?i:\A[a-z_][a-z0-9_]*=[^\0]*\z)/],Sensitive[Pattern[/(?i:\A[a-z_][a-z0-9_]*=[^\0]*\z)/]]]]
