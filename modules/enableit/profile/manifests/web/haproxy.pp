# @param version The version of haproxy. Defaults to 'present'.
#
# @param acme_contact The contact email for Let's Encrypt ACME. Defaults to 'ops@enableit.dk'.
#
# @param encryption_ciphers The encryption ciphers to use. Defaults to 'Modern'.
#
# @param firewall The firewall configurations. Defaults to an empty hash.
#
# @param log_compressed Boolean to enable or disable compressed logs.
#
# @groups security ddos_protection, https, use_hsts, use_lets_encrypt, encryption_ciphers, acme_contact
#
# @groups configuration manual_config, configure, version
#
# @groups networking domains, listens, firewall
#
# @groups logging log_compressed
#
# @groups mode http
#
class profile::web::haproxy (
  Enum['auto', 'manual']        $configure,
  Optional[String]              $manual_config,
  Eit_haproxy::Domains          $domains                = {},
  Eit_haproxy::Listen           $listens                = {},
  Boolean                       $ddos_protection        = false,
  Boolean                       $https                  = true,
  Boolean                       $http                   = false,
  Boolean                       $use_hsts               = true,
  Boolean                       $use_lets_encrypt       = true,
  Eit_types::Version            $version                = 'latest',
  Eit_types::Email              $acme_contact           = 'ops@enableit.dk',
  Enum['Modern','Intermediate'] $encryption_ciphers     = 'Modern',
  Hash[Eit_types::IP,Variant[
      Array[Stdlib::Port],
      Stdlib::Port
  ]]                            $firewall               = {},
  Boolean                       $log_compressed         = true,
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
    acme_contact       => $acme_contact,
    ca_type            => 'production',
    use_hsts           => $use_hsts,
    mode               => 'http',
    listen_on          => ['0.0.0.0'],
    manual_config      => $manual_config,
    configure          => $configure,
    firewall           => $firewall,
    encryption_ciphers => $encryption_ciphers,
    service_options    => {},
    log_compressed     => $log_compressed,
    log_dir            => '/var/log',
  }

  # Cleanup deprecated log summary sender
  service { ['obmondo-haproxy-script.timer', 'obmondo-haproxy-script.service']:
    ensure => 'stopped',
    enable => false,
    before => Package['obmondo-haproxy-script'],
  }

  package { 'obmondo-haproxy-script':
    ensure => 'purged',
  }

  file { '/etc/default/obmondo-haproxy-script':
    ensure => 'absent',
  }
}
