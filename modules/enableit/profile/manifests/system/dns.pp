# DNS client handling
class profile::system::dns (
  Enum['dnsmasq', 'systemd-resolved', 'resolv']       $resolver             = $common::system::dns::resolver,
  Array                                               $nameservers          = $common::system::dns::nameservers,
  Array                                               $fallback_nameservers = $common::system::dns::fallback_nameservers,
  Array[Eit_types::Hostname]                          $searchpath           = $common::system::dns::searchpath,
  Optional[Variant[Boolean, Enum['allow-downgrade']]] $dnssec               = $common::system::dns::dnssec,
  Optional[Variant[Boolean, Enum['opportunistic']]]   $dns_over_tls         = $common::system::dns::dns_over_tls,
  Array[Stdlib::IP::Address]                          $listen_address       = $common::system::dns::listen_address,
  Boolean                                             $allow_external       = $common::system::dns::allow_external,
  Variant[Undef, Boolean]                             $noop_value           = $common::system::dns::noop_value,
) {

  $_resolvers = ['dnsmasq', 'systemd-resolved']
  $_other_resolvers = $_resolvers - [$resolver]
  $_other_resolver_services = $_other_resolvers.map |$_resolver| {
    "${_resolver}.service"
  }

  File {
    noop => $noop_value,
  }

  Firewall {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  case $resolver {
    'dnsmasq': {
      $_nameservers = $nameservers.map |$_ns| {
        "nameserver ${_ns}\n"
      }.join("\n")

      firewall_multi { '110 allow external dns':
        ensure => ensure_present($allow_external),
        dport  => 53,
        proto  => [
          'tcp',
          'udp',
        ],
        jump   => 'accept',
      }

      file { '/etc/resolv.dnsmasq':
        ensure  => 'file',
        content => @("EOT"/$n)
          # MANAGED BY PUPPET; CAVEAT LECTOR
          ${_nameservers}
          | EOT
      }

      package { 'dnsmasq':
        ensure => 'installed',
        noop   => $noop_value,
        before => Service[$_other_resolver_services],
      }

      file { '/etc/dnsmasq.conf':
        content => epp('profile/system/dnsmasq.conf.epp', {
          port          => 53,
          listen        => [
            '::1',
            '127.0.0.1',
            '127.0.0.53',
          ]+$listen_address,
          domain_needed => false,
          bogus_priv    => false,
        }),
        require => Package['dnsmasq'],
        notify  => Service['dnsmasq.service'],
      }

      class { 'resolv_conf':
        nameservers => ['127.0.0.1'],
        require     => [
          Service['dnsmasq.service'],
          File['/etc/resolv.dnsmasq'],
        ]
      }

      common::services::systemd { 'dnsmasq.service':
        ensure     => true,
        enable     => true,
        override   => true,
        noop_value => $noop_value,
        service    => [
          {
            'Type'          => 'simple',
            'ExecStartPre'  => '/usr/sbin/dnsmasq --test',
            'ExecStartPost' => '',
            'ExecStop'      => '',
          },
          # This is required to override `ExecStart`. Debian-based distros have
          # dnsmasq running as a forking server, while RHEL-based have it
          # running as a foreground service -- we prefer the latter.
          {
            'ExecStart' => '',
          },
          {
            'ExecStart' => '/usr/sbin/dnsmasq -k',
          },

        ],
        require    => [
          File['/etc/resolv.dnsmasq'],
          File['/etc/dnsmasq.conf'],
          Package['dnsmasq'],
          Service[$_other_resolver_services],
        ]
      }

    }
    'systemd-resolved': {
      # NOTE: migrated to profile::system::systemd
    }
    'resolv': {

      class { 'resolv_conf':
        nameservers => $nameservers,
        searchpath  => $searchpath,
        options     => [
          'timeout:2',
          'rotate',
        ],
      }
    }
    default: {
      fail("Unknown resolver ${resolver}")
    }
  }

  # we only want to add this firewall rule if we use a resolver that binds to
  # `0.0.0.0` (systemd-resolved notably doesn't) and if we have set an IP range
  # for Docker
  if $resolver in ['dnsmasq', 'systemd-resolved'] {
    if has_role('role::virtualization::docker') or has_role('role::projectmanagement::gitlab_ci_runner') {
      $_docker_ip_range = lookup('role::virtualization::docker::fixed_cidr', Optional[String], undef, undef)
      if $_docker_ip_range {
        firewall_multi { '100 allow dns from docker containers':
          ensure => 'present',
          dport  => 53,
          proto  => [
            'tcp',
            'udp',
          ],
          source => $_docker_ip_range,
          jump   => 'accept',
        }
      }
    }
  }

  # ensure other resolvers are stopped
  service { $_other_resolver_services:
    ensure => 'stopped',
    enable => false,
  }

}
