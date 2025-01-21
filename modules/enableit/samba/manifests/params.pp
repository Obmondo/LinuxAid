# Class: samba::params
#
class samba::params {

  case $facts['os']['family'] {
    'RedHat': {
      if $facts['os']['release']['major'] == '5' {
        $service = [ 'smb' ]
      } else {
        $service = [ 'smb', 'nmb' ]
      }
      $secretstdb = '/var/lib/samba/private/secrets.tdb'
      $config_file = '/etc/samba/smb.conf'
      $package = 'samba'
    }
    'Debian': {
      if $facts['os']['family'] == 'Debian' and versioncmp($facts['os']['release']['full'], '8') < 0 {
        $service = [ 'samba' ]
      } else {
        $service = [ 'smbd', 'nmbd' ]
      }
      if $facts['os']['family'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '14') >= 0 {
        $secretstdb = '/var/lib/samba/private/secrets.tdb'
      } else {
        $secretstdb = '/var/lib/samba/secrets.tdb'
      }
      $config_file = '/etc/samba/smb.conf'
      $package = 'samba'
    }
    'Freebsd': {
      $service = [ 'samba' ]
      $secretstdb = '/var/lib/samba/secrets.tdb'
      $config_file = '/usr/local/etc/smb.conf'
      $package = 'samba36'
    }
    default: {
      $service = [ 'samba' ]
      $secretstdb = '/usr/local/samba/private/secrets.tdb'
      $config_file = '/etc/samba/smb.conf'
      $package = 'samba'
    }
  }

}
