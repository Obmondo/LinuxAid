
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
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups database dbroot, dbpass, redispass, sogo_url_encryption_key.
#
# @groups domain domain.
#
# @groups install version.
#
# @groups backup backup_dir.
#
# @groups management manage, letsencrypt, skip_unbound_healthcheck.
#
# @groups exporter exporter_api_key.
#
# @groups other timezone, extra_settings, encrypt_params.
#
# @encrypt_params dbroot, dbpass, redispass, exporter_api_key, sogo_url_encryption_key.
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

  Eit_types::Encrypt::Params $encrypt_params = [
    'dbroot',
    'dbpass',
    'redispass',
    'exporter_api_key',
    'sogo_url_encryption_key',
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
