# NetBackup client install
class netbackup::client::install (
  $installer          = $netbackup::client::installer,
  $version            = $netbackup::client::version,
  $masterserver       = $netbackup::client::masterserver,
  $clientname         = $netbackup::client::clientname,
  $tmpinstaller       =  $netbackup::client::tmpinstaller
){

  file { 'install_netbackup_client.expect':
    path    => "${tmpinstaller}/install_netbackup_client.expect",
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template('netbackup/install_netbackup_client.expect.erb'),
  }

  package { 'expect':
    ensure => installed,
  }

  exec { 'run-netbackup-install':
    command => "expect ${tmpinstaller}/install_netbackup_client.expect",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => [Package['expect'], File['install_netbackup_client.expect']],
    unless  => "grep ${version} /usr/openv/netbackup/bin/version",
  }

}
