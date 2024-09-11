class ssh::server::service (
  String  $ensure = 'running',
  Boolean $enable = true
){
  include ::ssh::params
  include ::ssh::server

  exec { 'force reload sshd':
    command     => 'pkill -HUP -f /usr/sbin/sshd',
    path        => ['/usr/bin', '/bin'],
    noop        => false,
    subscribe   => File['/etc/ssh/sshd_config'],
    refreshonly => true,
  }

  service { $ssh::params::service_name:
    ensure     => $ssh::server::service::ensure,
    hasstatus  => true,
    hasrestart => true,
    noop       => false,
    enable     => $ssh::server::service::enable,
    require    => Class['ssh::server::config'],
    notify     => Exec['force reload sshd']
  }
}
