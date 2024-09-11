# Valid .rpm version string.
# See http://www.perlmonks.org/?node_id=237724
type Cron::Rpm_version = Pattern[/\A[^-]+(-[^-])?\z/]
