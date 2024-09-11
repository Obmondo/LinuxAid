# # Making life easier
define dnsmasq::dhcp_host (
  String                    $mac,
  Optional[String[1]]       $hostname = undef,
  Optional[String[1]]       $ip       = undef,
  String                    $prio     = '99',
  Enum['present', 'absent'] $ensure   = 'present'
) {
  $h_real = $hostname ? {
    undef   => $name,
    default => $hostname,
  }
  $add_real = $ip ? {
    undef   => $h_real,
    default => "${h_real},${ip}",
  }

  dnsmasq::conf { "dhcp-host_${h_real}_${mac}":
    ensure  => $ensure,
    content => "dhcp-host=${mac},id:*,${add_real}\n",
    prio    => $prio,
    notify  => Exec['/usr/bin/pkill -HUP dnsmasq'],
  }
}
