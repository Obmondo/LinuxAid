# NetBackup client installation
class netbackup::client (
  Stdlib::Host         $masterserver,
  Stdlib::Absolutepath $installer,
  Optional[String]     $version         = undef,
  Stdlib::Host         $clientname      = $facts['networking']['fqdn'],
  Array[Stdlib::Host]  $mediaservers    = [],
  Boolean              $service_enabled = true,
  Array[String]        $excludes        = [],
  Stdlib::Absolutepath $tmpinstaller    = '/tmp'
)
{

  $_version_cmp = versioncmp($version, $facts['netbackup_version'])
  if $_version_cmp == 1 {
    # $version is newer than installed
    class { 'netbackup::client::install':
      before => Class['netbackup::client::config']
    }
  } elsif $_version_cmp == -1 {
    # $version is older than installed
    fail("Installed version ${facts['netbackup_version']} newer then ${version}, not downgrading")
  }

  class { 'netbackup::client::config': }
}
