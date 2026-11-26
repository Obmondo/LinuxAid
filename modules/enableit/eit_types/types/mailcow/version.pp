# Mailcow release tag, e.g. 2026-11 or 2026-11b
# https://github.com/mailcow/mailcow-dockerized/releases
type Eit_types::Mailcow::Version = Pattern[/\A20[0-9]{2}-[0-9]{2}[a-z]?\z/]
