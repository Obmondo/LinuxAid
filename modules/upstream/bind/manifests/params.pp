# Class: bind::params
#
class bind::params {

  case $facts['os']['family'] {
    'RedHat': {
      $packagenameprefix = 'bind'
      $servicename       = 'named'
      $binduser          = 'root'
      $bindgroup         = 'named'
      $file_hint         = 'named.ca'
      $file_rfc1912      = '/etc/named.rfc1912.zones'
      if versioncmp($facts['os']['release']['major'], '8') >= 0 {
        $file_bindkeys   = '/etc/named.root.key'
      } else {
        $file_bindkeys   = '/etc/named.iscdlv.key'
      }
    }
    'Debian': {
      $packagenameprefix = 'bind9'
      $servicename       = 'bind9'
      $binduser          = 'bind'
      $bindgroup         = 'bind'
      $file_hint         = '/etc/bind/db.root'
      $file_rfc1912      = '/etc/bind/named.conf.default-zones'
      $file_bindkeys     = '/etc/named.iscdlv.key'
    }
    'Freebsd': {
      $packagenameprefix = 'bind910'
      $servicename       = 'named'
      $binduser          = 'bind'
      $bindgroup         = 'bind'
      $file_hint         = 'named.ca'
      $file_rfc1912      = '/etc/named.rfc1912.zones'
      $file_bindkeys     = '/etc/named.iscdlv.key'
    }
    default: {
      $packagenameprefix = 'bind'
      $servicename       = 'named'
      $binduser          = 'root'
      $bindgroup         = 'named'
      $file_hint         = 'named.ca'
      $file_rfc1912      = '/etc/named.rfc1912.zones'
      $file_bindkeys     = '/etc/named.iscdlv.key'
    }
  }

}

