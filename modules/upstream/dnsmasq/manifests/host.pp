define dnsmasq::host (
  String                    $ip,
  String                    $hostname = undef,
  String                    $aliases  = undef,
  Boolean                   $mac      = false,
  Enum['present', 'absent'] $ensure   = 'present',
) {
  $h_real = $hostname ? {
    undef   => $name,
    default => $hostname,
  }

  if $mac != false {
    $mac_r = inline_template('<%= mac.upcase! %>')

    $mac_ensure = $mac ? {
      ''      => 'absent',
      default => $ensure,
    }

    @@file_line { "dnsmasq::ethers ${h_real} ${mac_r}":
      ensure => $mac_ensure,
      path   => '/etc/ethers',
      line   => "${mac_r} ${ip}",
      tag    => 'dnsmasq-host',
      notify => Class['dnsmasq::reload'],
    }
  }

  $al_add = $aliases ? {
    undef   => '',
    default => " ${aliases}",
  }

  $ip_ensure = $ip ? {
    ''      => 'absent',
    default => $ensure,
  }

  @@file_line { "dnsmasq::hosts ${h_real} ${ip}":
    ensure => $ip_ensure,
    path   => '/etc/hosts',
    line   => "${ip} ${h_real}${al_add}",
    tag    => 'dnsmasq-host',
    notify => Class['dnsmasq::reload'],
  }
}
