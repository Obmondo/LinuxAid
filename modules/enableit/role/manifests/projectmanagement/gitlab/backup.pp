# @summary Backup settings for GitLab, used when `backup` is enabled
#
# @param cron_hour The hour of day the backup cron runs. Defaults to 2.
#
# @param keep_days The number of days to keep backups. Defaults to 7.
#
# @param path The directory backups are written to. Defaults to undef.
#
# @param cron_user The user the backup cron runs as. Defaults to 'root'.
#
# @param public_keys The public keys the backup is encrypted to. Mandatory when backup is enabled.
#
# @groups backup cron_hour, keep_days, path, cron_user, public_keys
#
class role::projectmanagement::gitlab::backup (
  Integer[0,23]                  $cron_hour   = 2,
  Integer[1,default]             $keep_days   = 7,
  Optional[Stdlib::Absolutepath] $path        = undef,
  Eit_types::User                $cron_user   = 'root',
  Array[String]                  $public_keys = [],
) {
}
