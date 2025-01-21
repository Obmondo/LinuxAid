# Setups repo for installing passenger from upstream
class passenger::repo {

  case $facts['os']['family'] {
    'Debian' : {
      # sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
      # sudo apt-get install -y apt-transport-https ca-certificates
      # sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
      # Key id genereted from this command `gpg --status-fd 1 --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7`

      ensure_packages(['apt-transport-https', 'ca-certificates'])

      if ( ! defined(Class['apt']) ) {
        class { 'apt': }
      }

      apt::source { 'passenger_repository' :
        comment  => 'Phusion Passenger Repository',
        location => 'https://oss-binaries.phusionpassenger.com/apt/passenger',
        key      => {
          'id'     => '16378A33A6EF16762922526E561F9B9CAC40B2F7',
          'server' => 'keyserver.ubuntu.com',
        },
        include  => {
          'deb' => true
        }
      }
    }
    'RedHat' : {
      # sudo yum install -y epel-release pygpgme curl
      # sudo curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo

      ensure_packages(['epel-release', 'pygpgme', 'curl'])

      yumrepo { 'passenger' :
        name          => 'passenger',
        baseurl       => "https://oss-binaries.phusionpassenger.com/yum/passenger/el/\$releasever/\$basearch",
        repo_gpgcheck => '1',
        gpgcheck      => '0',
        enabled       => '1',
        gpgkey        => 'https://packagecloud.io/gpg.key',
        sslverify     => '1',
        sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt'
      }
    }
    default : {
      fail('unsupported os')
    }
  }
}
