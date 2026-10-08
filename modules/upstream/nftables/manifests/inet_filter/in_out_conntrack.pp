# @summary manage input & output conntrack
class nftables::inet_filter::in_out_conntrack {
  nftables::rule {
    'INPUT-accept_established_related':
      order   => '05',
      content => 'ct state established,related accept';
    'OUTPUT-accept_established_related':
      order   => '05',
      content => 'ct state established,related accept';
  }
  if $nftables::in_out_drop_invalid {
    nftables::rule { 'INPUT-drop_invalid':
      order   => '06',
      content => 'ct state invalid drop',
    }
    nftables::rule { 'OUTPUT-drop_invalid':
      order   => '06',
      content => 'ct state invalid drop';
    }
  }
}
