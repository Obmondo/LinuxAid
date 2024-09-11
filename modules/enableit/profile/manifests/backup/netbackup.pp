# NetBackup
class profile::backup::netbackup (
  Stdlib::Absolutepath        $installer_path      = $::common::backup::netbackup::installer_path,
  Eit_types::Version          $version             = $::common::backup::netbackup::version,
  Stdlib::Host                $master_server       = $::common::backup::netbackup::master_server,
  Array[Stdlib::Host, 1]      $media_servers       = $::common::backup::netbackup::media_servers,
  Array[Stdlib::Absolutepath] $excludes            = $::common::backup::netbackup::excludes,
  Pattern[/\A[A-Z]{16}\Z/]    $authorization_token = $::common::backup::netbackup::authorization_token,
  String                      $ca_cert             = $::common::backup::netbackup::ca_cert,
) {

  file { ['/usr/openv',
          '/usr/openv/var']:
    ensure => directory,
    owner  => 'root',
    group  => 'bin',
  }

  file { '/usr/openv/var/webtruststore':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => File['/usr/openv/var'],
  }


  file { '/usr/openv/var/webtruststore/cacert.pem':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => $ca_cert,
    require => File['/usr/openv/var/webtruststore'],
    before  => Class['netbackup::client'],
  }

  class { 'netbackup::client':
    installer       => $installer_path,
    version         => $version,
    service_enabled => true,
    masterserver    => $master_server,
    mediaservers    => $media_servers,
    excludes        => $excludes,
  }

  # Based on https://www.veritas.com/support/en_US/article.100002391
  firewall_multi {
    default:
      ensure => 'present',
      proto  => 'tcp',
      jump   => 'accept',
      ;

    '200 netbackup pbx master to client tcp 1556':
      dport  => 1556,
      source => $master_server,
      ;

    '200 netbackup pbx media to client tcp 1556':
      dport  => 1556,
      source => $media_servers,
      ;
  }

  firewall_multi {
    default:
      ensure => 'present',
      proto  => 'tcp',
      jump   => 'accept',
      chain  => 'OUTPUT',
      ;
    '200 netbackup client to master tcp 1566':
      dport       => [
        1556
      ],
      destination => $master_server,
      ;

    '200 netbackup client to media tcp spad/10102 spoold/10082':
      dport       => [
        10102,
        10082,
      ],
      destination => $media_servers,
      ;

  }

}
