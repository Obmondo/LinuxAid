# @summary Class for managing Haproxy
#
# @param service_options Additional options for the haproxy service.
#
# @param defaults_file_path The absolute path to the defaults file.
#
# @param configure The configuration method to use.
#
# @param domains The domains to be managed by haproxy.
#
# @param listens The listening configurations for haproxy.
#
# @param firewall The firewall configurations.
#
# @param restart_command The command to restart haproxy.
#
# @param manual_config Optional manual configuration for the haproxy.
#
# @param ddos_protection Boolean to enable or disable DDoS protection. Defaults to false.
#
# @param https Boolean to enable or disable HTTPS. Defaults to true.
#
# @param http Boolean to enable or disable HTTP. Defaults to false.
#
# @param use_hsts Boolean to enable or disable HSTS. Defaults to true.
#
# @param use_lets_encrypt Boolean to enable or disable Let's Encrypt. Defaults to true.
#
# @param mode The mode of haproxy. Defaults to 'http'.
#
# @param listen_on The IP addresses for haproxy to listen on. Defaults to ['0.0.0.0'].
#
# @param encryption_ciphers The encryption ciphers to use. Defaults to 'Modern'.
#
# @param version The version of haproxy. Defaults to 'latest'.
#
# @param acme_contact The contact email for Let's Encrypt ACME. Defaults to 'ops@enableit.dk'.
#
# @param ca_type ACME CA type. Use 'production' or 'staging'. Defaults to 'production'.
#
# @param service_ensure The desired state of the haproxy service. Defaults to true.
#
# @param service_enable Whether the haproxy service should be enabled. Defaults to true.
#
# @param service_name The name of the haproxy service. Defaults to 'haproxy'.
#
# @param log_compressed Boolean to enable or disable compressed logs. Defaults to false.
#
# @param log_dir The directory for log files. Defaults to '/var/log'.
#
# @groups security ddos_protection, https, use_hsts, use_lets_encrypt, encryption_ciphers, acme_contact, ca_type
#
# @groups configuration manual_config, configure, service_options, version, defaults_file_path, restart_command
#
# @groups networking domains, listens, listen_on, firewall
#
# @groups logging log_compressed, log_dir
#
# @groups service service_ensure, service_enable, service_name
#
# @groups mode mode, http
#
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
  Eit_types::Version            $version            = 'latest',
  Eit_types::Email              $acme_contact       = 'ops@enableit.dk',
  Enum['production','staging']  $ca_type            = 'production',
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
    $_is_ubuntu = $facts['os']['name'] == 'Ubuntu'
    $_wants_haproxy3 = if String($version) =~ Pattern[/^3(\.|$)/] {
      versioncmp(String($version), '3.2.0') >= 0
    } else {
      false
    }
    $_use_native_acme = $_is_ubuntu and $_wants_haproxy3

    $_acme_ca = $ca_type ? {
      'staging'    => 'https://acme-staging-v02.api.letsencrypt.org/directory',
      default      => 'https://acme-v02.api.letsencrypt.org/directory',
    }

    if $_wants_haproxy3 {
      if $_is_ubuntu {
        contain apt

        $haproxy_lts_version = '3.2'
        apt::ppa { "ppa:vbernat/haproxy-${haproxy_lts_version}": }

        Class['apt'] -> Apt::Ppa["ppa:vbernat/haproxy-${haproxy_lts_version}"] -> Class['eit_haproxy::basic_config']
      } else {
        warning('HAProxy 3.x auto-native ACME path is only supported on Ubuntu')
      }
    }

    if $_use_native_acme {
      ensure_packages(['socat', 'openssl', 'ssl-cert'])

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

      $_dump_timer = @(EOT)
        [Unit]
        Description=Dump HAProxy in-memory certificates to disk
        Requires=haproxy-dump-certs.service
        [Timer]
        OnCalendar=*-*-* 03:00:00
        RandomizedDelaySec=5m
        | EOT

      $_dump_service = @(EOT)
        [Unit]
        Description=Dump HAProxy in-memory certificates to disk
        [Service]
        Type=oneshot
        ExecStart=/bin/bash -c '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | /usr/bin/awk "/^\*/ {print $2}" | /usr/bin/xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/'
        | EOT

      systemd::timer { 'haproxy-dump-certs.timer':
        ensure          => present,
        timer_content   => $_dump_timer,
        service_content => $_dump_service,
        active          => true,
        enable          => true,
        require         => [File['/opt/obmondo/bin/haproxy-dump-certs.sh'], Package['socat']],
      }
    }

    # NOTE: Needed this, we install our own haproxy 2.9 on centos7
    if versioncmp($facts.dig('haproxy_version'), '2.5.0') >= 0 {
      $_acme_flush = if $_use_native_acme { @(EOT)
        ExecReload=/bin/bash -c '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | /usr/bin/awk "/^\*/ {print $2}" | /usr/bin/xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/'
        ExecStop=/bin/bash -c '/usr/bin/socat - /var/run/haproxy.sock <<< "show ssl cert" | /usr/bin/awk "/^\*/ {print $2}" | /usr/bin/xargs -r /opt/obmondo/bin/haproxy-dump-certs.sh -s /var/run/haproxy.sock -p /etc/ssl/private/'
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
      native_acme        => $_use_native_acme,
      ddos_protection    => $ddos_protection,
      https              => $https,
      http               => $http,
      use_hsts           => $use_hsts,
      use_lets_encrypt   => if $_use_native_acme { false } else { $use_lets_encrypt },
      acme_contact       => $acme_contact,
      acme_ca            => $_acme_ca,
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
