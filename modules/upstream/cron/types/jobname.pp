# Valid $title parameter to Cron::Job.
# This is the name of the /etc/cron.d/ file.
# The Ubuntu run-parts manpage specifies (^[a-zA-Z0-9_-]+$).
# For Cronie, the documentation is (unfortunately) in the code:
# - Ignore files starting with "." or "#"
# - Ignore the CRON_HOSTNAME file (default ".cron.hostname").
# - Ignore files whose length is zero or greater than NAME_MAX (default 255).
# - Ignore files whose name ends in "~".
# - Ignore files whose name ends in ".rpmsave", ".rpmorig", or ".rpmnew".
# We will use the most restrictive combination.
# See http://manpages.ubuntu.com/manpages/zesty/en/man8/run-parts.8.html
# See https://github.com/cronie-crond/cronie/blob/master/src/database.c#L625
type Cron::Jobname = Pattern[/(?i:\A[a-z0-9_-]{1,255}\z)/]
