# TFTP server
class razor::tftp (
  Eit_types::Network::PortRange $tftp_port_range,
) inherits ::razor {

  $_tftp_port_range = "${tftp_port_range[0]}:${tftp_port_range[1]}"

  package { 'tftpd-hpa':
    ensure => 'present',
  }


  common::services::systemd { 'tftpd-hpa.service' :
    ensure   => true,
    override => true,
    service  => [
      {'ExecStart' => ''},
      {'ExecStart' => "/usr/sbin/in.tftpd --listen --blocksize 1400 -s /var/lib/tftpboot --port-range ${tftp_port_range[0]}:${tftp_port_range[1]}"} # lint:ignore:140chars
    ],
  }

  firewall_multi { '100 allow tftpd':
    dport => [
      69,
      "${tftp_port_range[0]}-${tftp_port_range[1]}",
    ],
    proto => 'udp',
    jump  => 'accept',
  }

}
