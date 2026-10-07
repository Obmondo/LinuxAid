# @summary manage in ftp (with conntrack helper)
#
# @param enable_passive
#   Enable FTP passive mode support
#
# @param passive_ports
#   Set the FTP passive mode port range
#
class nftables::rules::ftp (
  Boolean $enable_passive = true,
  Nftables::Port::Range $passive_ports = '10090-10100',
) {
  nftables::helper { 'ftp-standard':
    content => ' type "ftp" protocol tcp;',
  }
  nftables::chain { 'PRE': }
  nftables::rule {
    'PRE-type':
      order   => '01',
      content => 'type filter hook prerouting priority filter';
    'PRE-policy':
      order   => '02',
      content => 'policy accept';
    'PRE-helper':
      order   => '03',
      content => 'tcp dport 21 ct helper set "ftp-standard"';
  }
  nftables::rule { 'default_in-ftp':
    content => 'tcp dport 21 accept',
  }
  if $enable_passive {
    nftables::rule { 'INPUT-ftp':
      order   => '10',
      content => "ct helper \"ftp\" tcp dport ${passive_ports} accept",
    }
  } else {
    nftables::rule { 'INPUT-ftp':
      order   => '10',
      content => 'ct helper "ftp" accept',
    }
  }
}
