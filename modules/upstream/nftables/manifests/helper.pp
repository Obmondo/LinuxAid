# @summary manage a conntrack helper
#
# @example FTP helper
#  nftables::helper { 'ftp-standard':
#    content => 'type "ftp" protocol tcp;',
#  }
#
# @param content
#   Conntrack helper definition.
# @param table
#   The name of the table to add this helper to.
# @param helper
#   The symbolic name for the helper.
define nftables::helper (
  String $content,
  Pattern[/^(ip|ip6|inet)-[a-zA-Z0-9_]+$/] $table = 'inet-filter',
  Pattern[/^[a-zA-Z0-9_][A-z0-9_-]*$/] $helper = $title,
) {
  $concat_name = "nftables-${table}-helper-${helper}"

  concat {
    $concat_name:
      path           => "/etc/nftables/puppet-preflight/${table}-helper-${helper}.nft",
      owner          => root,
      group          => root,
      mode           => $nftables::default_config_mode,
      ensure_newline => true,
      require        => Package['nftables'],
  } ~> Exec['nft validate'] -> file {
    "/etc/nftables/puppet/${table}-helper-${helper}.nft":
      ensure => file,
      source => "/etc/nftables/puppet-preflight/${table}-helper-${helper}.nft",
      owner  => root,
      group  => root,
      mode   => $nftables::default_config_mode,
  } ~> Service['nftables']

  concat::fragment {
    default:
      target => $concat_name;
    "${concat_name}-header":
      order   => '00',
      content => "# Start of fragment order:00 ${helper} header\nct helper ${helper} {";
    "${concat_name}-body":
      order   => '98',
      content => $content;
    "${concat_name}-footer":
      order   => '99',
      content => "# Start of fragment order:99 ${helper} footer\n}";
  }
}
