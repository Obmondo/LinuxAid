# Firewall setting
class lxc::firewall (
  String $bridge               = $lxc::bridge,
  Eit_types::IPv4CIDR $network = $lxc::network,
) {
  # Setup firewalls
  ensure_resource('firewall', "101 allow ${bridge}", {
    proto   => 'tcp',
    dport   => '53',
    iniface => $bridge,
    jump    => 'accept',
  })
  ensure_resource('firewall', "102 allow ${bridge}", {
    proto   => 'udp',
    dport   => '53',
    iniface => $bridge,
    jump    => 'accept',
  })
  ensure_resource('firewall', "103 allow ${bridge}", {
    proto   => 'tcp',
    dport   => '67',
    iniface => $bridge,
    jump    => 'accept',
  })
  ensure_resource('firewall', "104 allow ${bridge}", {
    proto   => 'udp',
    dport   => '67',
    iniface => $bridge,
    jump    => 'accept',
  })
  ensure_resource('firewall', "105 forward ${bridge}", {
    proto    => 'all',
    outiface => $bridge,
    jump     => 'accept',
    chain    => 'FORWARD',
  })
  ensure_resource('firewall', "106 forward ${bridge}", {
    proto   => 'all',
    iniface => $bridge,
    jump    => 'accept',
    chain   => 'FORWARD',
  })
  ensure_resource('firewall', "107 nat postrouting ${bridge}", {
    proto       => 'all',
    table       => 'nat',
    jump        => 'MASQUERADE',
    source      => "${network}/8",
    destination => "!${network}/8",
    chain       => 'POSTROUTING',
  })
  ensure_resource('firewall', "108 mangle postrouting ${bridge}", {
    proto         => 'udp',
    dport         => '68',
    table         => 'mangle',
    outiface      => $bridge,
    jump          => 'CHECKSUM',
    checksum_fill => true,
    chain         => 'POSTROUTING',
  })
}
