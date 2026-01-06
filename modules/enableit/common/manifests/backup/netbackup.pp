# @summary Class for managing NetBackup common backup configuration
#
# @param enable Enable or disable NetBackup backup. Defaults to false.
#
# @param installer_path Path to the installer directory.
#
# @param version The version of NetBackup.
#
# @param master_server The master server hostname.
#
# @param media_servers Array of media server hostnames, at least one required.
#
# @param authorization_token Authorization token matching 16 uppercase letters.
#
# @param ca_cert Path to the CA certificate.
#
# @param excludes List of paths to exclude from backup. Defaults to empty array.
#
# @groups activation enable.
#
# @groups installation installer_path, version.
#
# @groups servers master_server, media_servers.
#
# @groups security authorization_token, ca_cert.
#
# @groups configuration excludes.
#
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
