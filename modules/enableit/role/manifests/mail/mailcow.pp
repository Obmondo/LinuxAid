
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
# @param acme_contact The contact email for ACME. Defaults to undef.
#
# @param version The version of Mailcow to install. Defaults to '2024-08a'.
#
# @param install_dir The directory to install Mailcow. Defaults to '/opt/mailcow'.
#
# @param timezone The timezone for the installation. Defaults to 'Europe/Copenhagen'.
#
# @param extra_settings Additional settings for Mailcow. Defaults to an empty hash.
#
# @param backup_retention The number of days to keep backups. Defaults to 5.
#
# @param skip_unbound_healthcheck Flag to skip Unbound health check. Defaults to false.
#
# @param exporter_image The image for the Mailcow exporter. Defaults to 'ghcr.io/obmondo/dockerfiles/mailcow-exporter:1.4.0'.
#
# @param exporter_listen_address The address for the exporter to listen on. Defaults to '127.254.254.254:63382'.
#
# @param exporter_api_key The API Key to use when accessing the mailcow API
#
# @param http_bind The HTTP bind address. Defaults to '0.0.0.0'.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups database dbroot, dbpass, redispass.
#
# @groups domain domain.
#
# @groups install install_dir, version.
#
# @groups backup backup_dir, backup_retention.
#
# @groups management manage, letsencrypt, acme_contact, skip_unbound_healthcheck.
#
# @groups exporter exporter_image, exporter_listen_address, exporter_api_key.
#
# @groups http_settings http_bind.
#
# @groups other timezone, extra_settings, encrypt_params.
#
class role::mail::mailcow (
  String                      $dbroot,
  String                      $dbpass,
  String                      $redispass,
  Stdlib::Fqdn                $domain,
  Stdlib::Unixpath            $backup_dir               = '/opt/backup',
  Boolean                     $manage                   = true,
  Boolean                     $letsencrypt              = false,
  Optional[Eit_types::Email]  $acme_contact             = undef,
  Eit_types::Mailcow::Version $version                  = '2024-08a',
  Stdlib::Unixpath            $install_dir              = '/opt/mailcow',
  Eit_types::Timezone         $timezone                 = 'Europe/Copenhagen',
  Optional[Hash]              $extra_settings           = {},
  Integer[3,30]               $backup_retention         = 5,
  Optional[Boolean]           $skip_unbound_healthcheck = false,
  String                      $exporter_image           = 'ghcr.io/obmondo/dockerfiles/mailcow-exporter:1.4.0',
  Eit_types::IPPort           $exporter_listen_address  = '127.254.254.254:63382',
  String                      $exporter_api_key,
  Stdlib::IP::Address::V4::Nosubnet $http_bind  = '0.0.0.0',

  Eit_types::Encrypt::Params $encrypt_params = [
    'dbroot',
    'dbpass',
    'redispass',
    'exporter_api_key',
  ]

) {

  contain role::virtualization::docker

  class { 'profile::mail::mailcow':
    manage                   => $manage,
    version                  => $version,
    dbroot                   => $dbroot,
    dbpass                   => $dbpass,
    http_bind                => $http_bind,
    install_dir              => $install_dir,
    backup_dir               => $backup_dir,
    timezone                 => $timezone,
    domain                   => $domain,
    acme_contact             => lookup('common::certs::letsencrypt::email', Optional[Eit_types::Email], undef, $acme_contact),
    backup_retention         => $backup_retention,
    skip_unbound_healthcheck => $skip_unbound_healthcheck,
  }
}
