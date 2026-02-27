# @param version The version of haproxy. Defaults to 'present'.
#
# @param use_native_acme Boolean to enable or disable HAProxy 3.2+ native ACME. Defaults to false.
#
# @param acme_contact The contact email for Let's Encrypt ACME. Defaults to 'ops@enableit.dk'.
#
# @param acme_directory The ACME directory URL. Defaults to Let's Encrypt production.
#
# @param listen_on The IP addresses for haproxy to listen on. Defaults to ['0.0.0.0'].
#
# @param encryption_ciphers The encryption ciphers to use. Defaults to 'Modern'.
#
# @param firewall The firewall configurations. Defaults to an empty hash.
#
# @param service_options Additional options for the haproxy service. Defaults to an empty hash.
#
# @param log_compressed Boolean to enable or disable compressed logs.
#
# @param log_dir The directory for log files.
#
# @param send_log_summary Boolean to enable or disable sending log summaries.
#
# @param log_summary_recipients The recipients for log summaries.
#
# @groups security ddos_protection, https, use_hsts, use_lets_encrypt, encryption_ciphers, use_native_acme, acme_contact, acme_directory
#
# @groups configuration manual_config, configure, service_options, version
#
# @groups networking domains, listens, listen_on, firewall
#
# @groups logging log_compressed, log_dir, send_log_summary, log_summary_recipients
#
# @groups mode mode, http
#
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
  Boolean                       $use_native_acme        = false,
  String                        $acme_contact           = 'ops@enableit.dk',
  String                        $acme_directory         = 'https://acme-v02.api.letsencrypt.org/directory',
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
      contain common::monitor::exporter::haproxy
    }
  }

  #allow haproxy to listen on ips the host does not have (yet - as it runs keepalived)
  sysctl::configuration { 'net.ipv4.ip_nonlocal_bind':
    value => '1',
  }

  # Haproxy Setup
  class { 'eit_haproxy':
    domains            => $domains,
    listens            => $listens,
    version            => $version,
    ddos_protection    => $ddos_protection,
    https              => $https,
    http               => $http,
    use_lets_encrypt   => $use_lets_encrypt,
    use_native_acme    => $use_native_acme,
    acme_contact       => $acme_contact,
    acme_directory     => $acme_directory,
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
