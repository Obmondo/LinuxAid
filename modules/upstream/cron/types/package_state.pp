# Valid $ensure parameter to Package resource. Excludes version numbers.
type Cron::Package_state = Enum['absent', 'installed', 'held', 'latest', 'present', 'purged']
