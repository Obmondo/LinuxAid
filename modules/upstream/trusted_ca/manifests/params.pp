# @summary Default parameters
# @api private
class trusted_ca::params {
  $certificates_version = 'installed'

  case $facts['os']['family'] {
    'RedHat': {
      $path = ['/usr/bin', '/bin']
      $update_command = 'update-ca-trust extract'
      $install_path = '/etc/pki/ca-trust/source/anchors'
      $certfile_suffix = 'crt'
      $certs_package = 'ca-certificates'
    }
    'Debian': {
      $path = ['/bin', '/usr/bin', '/usr/sbin']
      $update_command = 'update-ca-certificates'
      $install_path = '/usr/local/share/ca-certificates'
      $certfile_suffix = 'crt'
      $certs_package = 'ca-certificates'
    }
    'Suse': {
      case $facts['os']['name'] {
        'SLES': {
          case $facts['os']['release']['major'] {
            '11': {
              $path = ['/usr/bin']
              $update_command = 'c_rehash'
              $install_path = '/etc/ssl/certs'
              $certs_package = 'openssl-certs'
              $certfile_suffix = 'pem'
            }
            default: {
              $path = ['/usr/sbin', '/usr/bin']
              $update_command = 'update-ca-certificates'
              $install_path = '/etc/pki/trust/anchors'
              $certs_package = 'ca-certificates'
              $certfile_suffix = 'crt'
            }
          }
        }
        'OpenSuSE': {
          $path = ['/usr/sbin', '/usr/bin']
          $update_command = 'update-ca-certificates'
          $install_path = '/etc/pki/trust/anchors'
          $certs_package = 'ca-certificates'
          $certfile_suffix = 'crt'
        }
        default: {
          fail("${facts['os']['family']}/${facts['os']['name']} not supported")
        }
      }
    }
    default: {
      fail("${facts['os']['family']}/${facts['os']['name']} ${facts['os']['release']['full']} not supported")
    }
  }
}
