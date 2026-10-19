# Offsite S3 bucket the mailcow backups are pushed to with restic
type Eit_types::Mailcow::S3backup = Struct[{
  endpoint                => Stdlib::HTTPUrl,
  bucket                  => Pattern[/\A[a-z0-9][a-z0-9.\-]{1,61}[a-z0-9]\z/],
  access_key_id           => String[1],
  secret_access_key       => String[1],
  password                => String[1],
  Optional[keep_daily]    => Integer[0],
  Optional[keep_weekly]   => Integer[0],
  Optional[keep_monthly]  => Integer[0],
}]
