# Mailcow Setup
class role::mail::mailcow (
  String                      $dbroot,
  String                      $dbpass,
  Stdlib::Fqdn                $domain,
  Stdlib::Unixpath            $backup_dir       = '/opt/backup',
  Boolean                     $manage           = true,
  Boolean                     $letsencrypt      = false,
  Optional[Eit_types::Email]  $acme_contact     = undef,
  Eit_types::Mailcow::Version $version          = '2024-08a',
  Stdlib::Unixpath            $install_dir      = '/opt/mailcow',
  Eit_types::Timezone         $timezone         = 'Europe/Copenhagen',
  Optional[Hash]              $extra_settings   = {},
  Integer[3,30]               $backup_retention = 5,

  Stdlib::IP::Address::V4::Nosubnet $http_bind  = '0.0.0.0',
) {

  contain role::virtualization::docker

  class { 'profile::mail::mailcow':
    manage           => $manage,
    version          => $version,
    dbroot           => $dbroot,
    dbpass           => $dbpass,
    http_bind        => $http_bind,
    install_dir      => $install_dir,
    backup_dir       => $backup_dir,
    timezone         => $timezone,
    domain           => $domain,
    acme_contact     => lookup('common::certs::letsencrypt::email', Optional[Eit_types::Email], undef, $acme_contact),
    backup_retention => $backup_retention,
  }
}
