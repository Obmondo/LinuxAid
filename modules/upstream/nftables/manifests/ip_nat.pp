# manage basic chains in table ip nat
class nftables::ip_nat inherits nftables {
  nftables::config {
    "ip-${nftables::nat_table_name}":
      prefix => '';
    "ip6-${nftables::nat_table_name}":
      prefix => '';
  }

  nftables::chain {
    [
      'PREROUTING',
      'POSTROUTING',
    ]:
      table => "ip-${nftables::nat_table_name}";
  }

  nftables::chain {
    [
      'PREROUTING6',
      'POSTROUTING6',
    ]:
      table => "ip6-${nftables::nat_table_name}";
  }

  # ip-nat-chain-PREROUTING
  nftables::rule {
    'PREROUTING-type':
      table   => "ip-${nftables::nat_table_name}",
      order   => '01',
      content => 'type nat hook prerouting priority -100';
    'PREROUTING-policy':
      table   => "ip-${nftables::nat_table_name}",
      order   => '02',
      content => 'policy accept';
    'PREROUTING6-type':
      table   => "ip6-${nftables::nat_table_name}",
      order   => '01',
      content => 'type nat hook prerouting priority -100';
    'PREROUTING6-policy':
      table   => "ip6-${nftables::nat_table_name}",
      order   => '02',
      content => 'policy accept';
  }

  # ip-nat-chain-POSTROUTING
  nftables::rule {
    'POSTROUTING-type':
      table   => "ip-${nftables::nat_table_name}",
      order   => '01',
      content => 'type nat hook postrouting priority 100';
    'POSTROUTING-policy':
      table   => "ip-${nftables::nat_table_name}",
      order   => '02',
      content => 'policy accept';
    'POSTROUTING6-type':
      table   => "ip6-${nftables::nat_table_name}",
      order   => '01',
      content => 'type nat hook postrouting priority 100';
    'POSTROUTING6-policy':
      table   => "ip6-${nftables::nat_table_name}",
      order   => '02',
      content => 'policy accept';
  }
}
