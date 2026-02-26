# Haproxy
class eit_haproxy (
  Hash                          $service_options,
  String                        $defaults_file_path,
  Enum['auto', 'manual']        $configure,
  Eit_haproxy::Domains          $domains,
  Eit_haproxy::Listen           $listens,
  Hash[Eit_types::IP,Variant[
      Array[Stdlib::Port],
      Stdlib::Port
  ]]                            $firewall,
  Optional[String]              $restart_command,

  Optional[String]              $manual_config,
  Boolean                       $ddos_protection    = false,
  Boolean                       $https              = true,
  Boolean                       $http               = false,
  Boolean                       $use_hsts           = true,
  Boolean                       $use_lets_encrypt   = true,
  Enum['http','tcp']            $mode               = 'http',
  Array[Stdlib::IP::Address,1]  $listen_on          = ['0.0.0.0'],
  Enum['Modern','Intermediate'] $encryption_ciphers = 'Modern',
  Eit_types::Package_version    $version            = 'present',
  Boolean                       $use_native_acme    = false,
  String                        $acme_contact       = 'ops@enableit.dk',
  String                        $acme_directory     = 'https://acme-v02.api.letsencrypt.org/directory',
  Eit_types::Service_Ensure     $service_ensure     = true,
  Eit_types::Service_Enable     $service_enable     = true,
  String                        $service_name       = 'haproxy',
  Boolean                       $log_compressed     = false,
  Stdlib::Absolutepath          $log_dir            = '/var/log',
) {
  if $configure == 'manual' {
    contain eit_haproxy::install
    contain eit_haproxy::service

    class { 'eit_haproxy::manual_config':
      config_file => $manual_config,
    }
  }

  if $configure == 'auto' {
    if $version == 'latest' {
      if $facts['os']['name'] == 'Ubuntu' and $facts['os']['distro']['codename'] == 'noble' {
        contain apt

        $haproxy_lts_version = '3.2'
        apt::ppa { "ppa:vbernat/haproxy-${haproxy_lts_version}": }

        Class['apt'] -> Apt::Ppa["ppa:vbernat/haproxy-${haproxy_lts_version}"] -> Class['eit_haproxy::basic_config']
      } else {
        warning('eit_haproxy::manage_community_repo is only supported on Ubuntu Noble')
      }
    }

    if $use_native_acme {
      contain eit_haproxy::dummy_cert
      Class['eit_haproxy::dummy_cert'] -> Class['eit_haproxy::basic_config']
    }

    # NOTE: Needed this, we install our own haproxy 2.9 on centos7
    if versioncmp($facts.dig('haproxy_version'), '2.5.0') >= 0 {
      $_service = @(EOT)
        [Service]
        ExecStartPre=
        ExecStartPre=/usr/sbin/haproxy -f $CONFIG -c -q
        | EOT

      systemd::dropin_file { 'haproxy_dropin':
        filename => 'haproxy-override.conf',
        unit     => 'haproxy.service',
        content  => $_service,
        notify   => Service['haproxy'],
      }
    }

    class { 'eit_haproxy::basic_config':
      domains            => $domains,
      version            => $version,
      ddos_protection    => $ddos_protection,
      https              => $https,
      http               => $http,
      use_hsts           => $use_hsts,
      use_lets_encrypt   => $use_lets_encrypt,
      use_native_acme    => $use_native_acme,
      acme_contact       => $acme_contact,
      acme_directory     => $acme_directory,
      listens            => $listens,
      mode               => $mode,
      listen_on          => $listen_on,
      encryption_ciphers => $encryption_ciphers,
    }
  }

  # Setup Firewall Rules
  contain eit_haproxy::firewall

  # Setup logs to send it to rsyslog
  contain eit_haproxy::log
}
