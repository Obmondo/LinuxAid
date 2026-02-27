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
      ensure_packages(['socat'])

      class { 'eit_haproxy::dummy_cert':
        domains => $domains,
      }
      Class['eit_haproxy::dummy_cert'] -> Class['eit_haproxy::basic_config']

      file { '/opt/obmondo/bin/haproxy-dump-certs.sh':
        ensure => file,
        source => 'puppet:///modules/eit_haproxy/haproxy-dump-certs.sh',
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
      }

      cron { 'haproxy-dump-certs':
        command => '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | awk "/^\*/ {print \$2}" | xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/ >/dev/null 2>&1',
        user    => 'root',
        minute  => '0',
        hour    => '3',
        require => [File['/opt/obmondo/bin/haproxy-dump-certs.sh'], Package['socat']],
      }
    }

    # NOTE: Needed this, we install our own haproxy 2.9 on centos7
    if versioncmp($facts.dig('haproxy_version'), '2.5.0') >= 0 {
      $_acme_flush = if $use_native_acme { @(EOT)
        ExecReload=/bin/bash -c '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | awk "/^\*/ {print $2}" | xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/'
        ExecStop=/bin/bash -c '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | awk "/^\*/ {print $2}" | xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/'
        | EOT
      } else { '' }

      $_service_base = @(EOT)
        [Service]
        ExecStartPre=
        ExecStartPre=/usr/sbin/haproxy -f $CONFIG -c -q
        | EOT

      $_service = "${_service_base}${_acme_flush}"

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
      use_lets_encrypt   => if $use_native_acme { false } else { $use_lets_encrypt },
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
