# Firewall Pre class
class std_fw::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    jump => 'accept',
  }
  -> firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    jump  => 'accept',
  }
  -> firewall { '002 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    jump => 'accept',
  }

  firewall { '003 allow ssh':
    proto  => 'tcp',
    dport  => 22,
    jump => 'accept',
  }
}
