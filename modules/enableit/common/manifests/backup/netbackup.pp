# NetBackup
class common::backup::netbackup (
  Boolean                     $enable = false,
  Stdlib::Absolutepath        $installer_path,
  Eit_types::Version          $version,
  Stdlib::Host                $master_server,
  Array[Stdlib::Host, 1]      $media_servers,
  Pattern[/\A[A-Z]{16}\Z/]    $authorization_token,
  String                      $ca_cert,
  Array[Stdlib::Absolutepath] $excludes = [],
) {

  if $enable {
    'profile::backup::netbackup'.contain
  }
}
