# iptables_api
class profile::software::iptables_api (
  Boolean           $enable         = $common::software::iptables_api::enable,
  Optional[Boolean] $noop_value     = $common::software::iptables_api::noop_value,
  Eit_types::IPPort $listen_address = $common::software::iptables_api::listen_address,
){

  $_listen_ip = $listen_address.split(':')[0]
  $_listen_port = $listen_address.split(':')[1]

  package { 'obmondo-iptables-api':
    ensure => ensure_present($enable),
    noop   => $noop_value,
    before => Service['iptables-api.service']
  }

  $_service_content = @("EOT"/$n)
    # THIS FILE IS MANAGED BY LINUXAID. CHANGES WILL BE LOST.
    [Unit]
    Description=iptables-api

    [Service]
    Type=simple
    Restart=always
    RestartSec=5s
    ExecStart=/opt/obmondo/bin/iptables-api -ip=${_listen_ip} -port=${_listen_port} -log=/var/log/iptables-api.access.log

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::unit_file { 'iptables-api.service':
    ensure => ensure_present($enable),
    enable => $enable,
    active => $enable,
    content => $_service_content,
  }

  firewall { '130 allow iptables_api':
    ensure   => ensure_present($enable and $listen_address !~ /^127\./),
    proto    => 'tcp',
    protocol => 'iptables',
    dport    => $listen_address.split(':')[1],
    jump     => 'accept',
  }
}
