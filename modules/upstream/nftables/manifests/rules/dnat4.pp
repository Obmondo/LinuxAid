# manage a ipv4 dnat rule
define nftables::rules::dnat4 (
  # lint:ignore:parameter_documentation
  Pattern[/^[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}$/] $daddr,
  Variant[String,Stdlib::Port] $port,
  Pattern[/^[a-zA-Z0-9_]+$/] $rulename = $title,
  Pattern[/^\d\d$/] $order = '50',
  String[1] $chain = 'default_fwd',
  Optional[String[1]] $iif = undef,
  Enum['tcp','udp'] $proto = 'tcp',
  Optional[Variant[String,Stdlib::Port]] $dport = undef,
  Enum['present','absent'] $ensure = 'present',
  # lint:endignore
) {
  $iifname = $iif ? {
    undef   => '',
    default => "iifname ${iif} ",
  }
  $filter_port = $dport ? {
    undef   => $port,
    default => $dport,
  }
  $nat_port = $dport ? {
    undef   => '',
    default => ":${dport}",
  }

  nftables::rule {
    default:
      ensure => $ensure,
      order  => $order;
    "${chain}-${rulename}":
      content => "${iifname}ip daddr ${daddr} ${proto} dport ${filter_port} accept";
    "PREROUTING-${rulename}":
      table   => "ip-${nftables::nat_table_name}",
      content => "${iifname}${proto} dport ${port} dnat to ${daddr}${nat_port}";
  }
}
