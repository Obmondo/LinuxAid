# Bind Profile
class profile::bind {
  # Firewall
  ['tcp', 'udp'].each |$proto| {
    firewall { "000 allow dns-${proto}":
      proto => $proto,
      dport => 53,
      jump  => 'accept',
    }
  }

  # Setup Bind
  contain bind::server
}
