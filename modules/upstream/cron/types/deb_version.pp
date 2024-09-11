# Valid .deb version string.
# See https://www.debian.org/doc/debian-policy/#s-f-version
type Cron::Deb_version = Pattern[/(?i:\A(((0|[1-9][0-9]*):)?[0-9]([a-z0-9.+-~]*|[a-z0-9.+~]*-[a-z0-9+.~]+))\z)/]
