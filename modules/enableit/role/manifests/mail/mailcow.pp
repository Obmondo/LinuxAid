
# @summary Mailcow Setup
#
# @param dbroot The root password for the database.
#
# @param dbpass The database password.
#
# @param redispass The password to connect to redis
#
# @param domain The fully qualified domain name.
#
# @param backup_dir The directory for backups. Defaults to '/opt/backup'.
#
# @param manage Flag to manage the service. Defaults to true.
#
# @param letsencrypt Flag to manage Let's Encrypt certificates. Defaults to false.
#
# @param version The mailcow release tag to install, e.g. '2026-11b'. Images and
#   compose settings follow the upstream docker-compose.yml of that tag.
#
# @param timezone The timezone for the installation. Defaults to 'Europe/Copenhagen'.
#
# @param extra_settings Additional settings for Mailcow. Defaults to an empty hash.
#
# @param skip_unbound_healthcheck Flag to skip Unbound health check. Defaults to false.
#
# @param exporter_api_key The API Key to use when accessing the mailcow API
#
# @param sogo_url_encryption_key Key SOGo uses to encrypt email addresses in its
#   URLs, exactly 16 characters A-Z, a-z, 0-9. Without it mailcow falls back to
#   its public default key.
#
# @param rspamd_ip_whitelist IPs or networks rspamd never scores as spam,
#   written to data/conf/rspamd/custom/ip_wl.map. Empty keeps the upstream file.
#
# @param backup_keep_days Days of local backups kept in backup_dir. Defaults to 5.
#
# @param offsite_s3_bucket S3 bucket the nightly backup is copied to, e.g.
#   's3://mailcow-backup/'. No offsite copy is made when unset.
#
# @param offsite_s3_endpoint S3 endpoint for the offsite copy.
#   Defaults to 'https://offsite.obmondo.com'.
#
# @param offsite_access_key_id Access key for the offsite bucket.
#
# @param offsite_secret_access_key Secret key for the offsite bucket.
#
# @param offsite_restic_password Password of the restic repository the offsite
#   copy is stored in (s3:<endpoint>/<bucket>/restic). Without it the offsite
#   backups cannot be read, so keep a copy outside this host.
#
# @param offsite_keep_daily Daily offsite snapshots kept. Defaults to 7.
#
# @param offsite_keep_weekly Weekly offsite snapshots kept on top of the daily
#   ones. Defaults to 4.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups database dbroot, dbpass, redispass, sogo_url_encryption_key.
#
# @groups domain domain.
#
# @groups install version.
#
# @groups backup backup_dir, backup_keep_days, offsite_s3_bucket, offsite_s3_endpoint, offsite_access_key_id, offsite_secret_access_key, offsite_restic_password, offsite_keep_daily, offsite_keep_weekly.
#
# @groups management manage, letsencrypt, skip_unbound_healthcheck, rspamd_ip_whitelist.
#
# @groups exporter exporter_api_key.
#
# @groups other timezone, extra_settings, encrypt_params.
#
# @encrypt_params dbroot, dbpass, redispass, exporter_api_key, sogo_url_encryption_key, offsite_secret_access_key, offsite_restic_password.
#
class role::mail::mailcow (
  String                      $dbroot,
  String                      $dbpass,
  String                      $redispass,
  Stdlib::Fqdn                $domain,
  Stdlib::Unixpath            $backup_dir               = '/opt/backup',
  Boolean                     $manage                   = true,
  Boolean                     $letsencrypt              = false,
  Eit_types::Mailcow::Version $version                  = '2026-11b',
  Eit_types::Timezone         $timezone                 = 'Europe/Copenhagen',
  Optional[Hash]              $extra_settings           = {},
  Optional[Boolean]           $skip_unbound_healthcheck = false,
  String                      $exporter_api_key,
  Optional[Pattern[/\A[A-Za-z0-9]{16}\z/]] $sogo_url_encryption_key = undef,
  Array[Stdlib::IP::Address]  $rspamd_ip_whitelist      = [],
  Integer[1]                  $backup_keep_days          = 5,
  Optional[Pattern[/\As3:\/\/[a-z0-9][a-z0-9.\-]*\/\z/]] $offsite_s3_bucket = undef,
  Stdlib::HTTPUrl             $offsite_s3_endpoint       = 'https://offsite.obmondo.com',
  Optional[String[1]]         $offsite_access_key_id     = undef,
  Optional[String[1]]         $offsite_secret_access_key = undef,
  Optional[String[1]]         $offsite_restic_password   = undef,
  Integer[1]                  $offsite_keep_daily        = 7,
  Integer[0]                  $offsite_keep_weekly       = 4,

  Eit_types::Encrypt::Params $encrypt_params = [
    'dbroot',
    'dbpass',
    'redispass',
    'exporter_api_key',
    'sogo_url_encryption_key',
    'offsite_secret_access_key',
    'offsite_restic_password',
  ]

) {

  contain role::virtualization::docker
  contain role::mail::mailcow::letsencrypt

  class { 'profile::mail::mailcow':
    manage                   => $manage,
    version                  => $version,
    dbroot                   => $dbroot,
    dbpass                   => $dbpass,
    backup_dir               => $backup_dir,
    domain                   => $domain,
    timezone                 => $timezone,
    acme_contact             => lookup('common::system::certs::letsencrypt::email', Optional[Eit_types::Email], undef, $role::mail::mailcow::letsencrypt::acme_contact),
    skip_unbound_healthcheck => $skip_unbound_healthcheck,
  }
}
