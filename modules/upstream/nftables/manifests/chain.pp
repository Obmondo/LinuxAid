# manage a chain
define nftables::chain (
  # lint:ignore:parameter_documentation
  Pattern[/^(ip|ip6|inet|netdev|bridge)-[a-zA-Z0-9_]+$/] $table = 'inet-filter',
  Pattern[/^[a-zA-Z0-9_]+$/] $chain = $title,
  Optional[Pattern[/^\d\d-[a-zA-Z0-9_]+$/]] $inject = undef,
  Optional[String] $inject_iif = undef,
  Optional[String] $inject_oif = undef,
  # lint:endignore
) {
  $concat_name = "nftables-${table}-chain-${chain}"

  concat {
    $concat_name:
      path           => "/etc/nftables/puppet-preflight/${table}-chain-${chain}.nft",
      owner          => root,
      group          => root,
      mode           => $nftables::default_config_mode,
      ensure_newline => true,
      require        => Package['nftables'],
  } ~> Exec['nft validate'] -> file {
    "/etc/nftables/puppet/${table}-chain-${chain}.nft":
      ensure => file,
      source => "/etc/nftables/puppet-preflight/${table}-chain-${chain}.nft",
      owner  => root,
      group  => root,
      mode   => $nftables::default_config_mode,
  } ~> Service['nftables']

  concat::fragment {
    default:
      target => $concat_name;
    "${concat_name}-header":
      order   => '00',
      content => "# Start of fragment order:00 ${chain} header\nchain ${chain} {";
    "${concat_name}-footer":
      order   => '99',
      content => "# Start of fragment order:99 ${chain} footer\n}";
  }

  if $inject {
    $data = split($inject, '-')
    $iif = $inject_iif ? {
      undef => '',
      default => "iifname ${inject_iif} ",
    }
    $oif = $inject_oif ? {
      undef => '',
      default => "oifname ${inject_oif} ",
    }
    nftables::rule { "${data[1]}-jump_${chain}":
      order   => $data[0],
      content => "${iif}${oif}jump ${chain}",
    }
  }
}
