# Haproxy Profile
class profile::haproxy (
  Enum['auto', 'manual']        $configure,
  Optional[String]              $manual_config,
  Eit_haproxy::Domains          $domains                = {},
  Eit_haproxy::Listen           $listens                = {},
  Boolean                       $ddos_protection        = false,
  Boolean                       $https                  = true,
  Boolean                       $http                   = false,
  Boolean                       $use_hsts               = true,
  Boolean                       $use_lets_encrypt       = true,
  Enum['http','tcp']            $mode                   = 'http',
  Eit_types::Package_version    $version                = 'present',
  Array[Stdlib::IP::Address,1]  $listen_on              = ['0.0.0.0'],
  Enum['Modern','Intermediate'] $encryption_ciphers     = 'Modern',
  Hash[Eit_types::IP,Variant[
    Array[Stdlib::Port],
    Stdlib::Port
  ]]                            $firewall               = {},
  Hash                          $service_options        = {},
  Boolean                       $log_compressed         = $role::web::haproxy::log_compressed,
  Stdlib::Absolutepath          $log_dir                = $role::web::haproxy::log_dir,
  Boolean                       $send_log_summary       = $role::web::haproxy::send_log_summary,
  Array[String]                 $log_summary_recipients = $role::web::haproxy::log_summary_recipients,
) inherits profile {

  # Monitoring
  $facts.dig('haproxy_version').then |$_haproxy_version| {
    # if version is >= 2.0.0
    if versioncmp($_haproxy_version, '2.0.0') >= 0 {
      contain ::common::monitor::exporter::haproxy
    }
  }

  #allow haproxy to listen on ips the host does not have (yet - as it runs keepalived)
  sysctl::configuration { 'net.ipv4.ip_nonlocal_bind':
    value => '1',
  }

  # Haproxy Setup
  class { '::eit_haproxy':
    domains            => $domains,
    listens            => $listens,
    version            => $version,
    ddos_protection    => $ddos_protection,
    https              => $https,
    http               => $http,
    use_lets_encrypt   => $use_lets_encrypt,
    use_hsts           => $use_hsts,
    mode               => $mode,
    listen_on          => $listen_on,
    manual_config      => $manual_config,
    configure          => $configure,
    firewall           => $firewall,
    encryption_ciphers => $encryption_ciphers,
    service_options    => $service_options,
    log_compressed     => $log_compressed,
    log_dir            => $log_dir,
  }

  # Install log summary sender
  if $send_log_summary {
    package::install('obmondo-haproxy-script', {
      ensure  => 'latest',
    })
    file_line { 'logdir_env_var':
      ensure  => 'present',
      line    => "LOGDIR='${log_dir}'",
      match   => 'LOGDIR=',
      path    => '/etc/default/obmondo-haproxy-script',
      require => Package['obmondo-haproxy-script'],
    }
    file_line { 'mailto_env_var':
      ensure  => 'present',
      line    => "MAILTO='${$log_summary_recipients.join(':')}'",
      match   => 'MAILTO=',
      path    => '/etc/default/obmondo-haproxy-script',
      require => Package['obmondo-haproxy-script'],
    }
  }
}
