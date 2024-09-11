# Firewall setting
class lxd::firewall (
  String $interface = 'lxdbr0',
  Eit_types::IP $network = '10.0.3.0'
) {

  # Setup firewall rules
  firewall {
    default:
      iniface => $interface,
      jump    => 'accept',
      ;

    "101 allow ${interface}":
      proto => 'tcp',
      dport => 53,
      ;

    "102 allow ${interface}":
      proto => 'udp',
      dport => 53,
      ;

    "103 allow ${interface}":
      proto => 'tcp',
      dport => 67,
      ;

    "104 allow ${interface}":
      proto => 'udp',
      dport => 67,
      ;

    "105 forward ${interface}":
      proto    => 'all',
      iniface  => undef,
      outiface => $interface,
      chain    => 'FORWARD',
      ;

    "106 forward ${interface}":
      proto => 'all',
      chain => 'FORWARD',
      ;

    "107 nat postrouting ${interface}":
      proto       => 'all',
      table       => 'nat',
      jump        => 'MASQUERADE',
      source      => "${network}/24",
      destination => "!${network}/24",
      chain       => 'POSTROUTING',
      iniface     => undef,
      action      => undef,
      ;

    "108 mangle postrouting ${interface}":
      proto         => 'udp',
      dport         => 68,
      table         => 'mangle',
      outiface      => $interface,
      jump          => 'CHECKSUM',
      checksum_fill => true,
      chain         => 'POSTROUTING',
      iniface       => undef,
      action        => undef,
    ;
  }
}
