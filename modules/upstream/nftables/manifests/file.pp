# @summary Insert a file into the nftables configuration
# @example Include a file that includes other files
#   nftables::file{'geoip':
#     content => @(EOT),
#       include "/var/local/geoipsets/dbip/nftset/ipv4/*.ipv4"
#       include "/var/local/geoipsets/dbip/nftset/ipv6/*.ipv6"
#       |EOT
#   }
#
# @param label Unique name to include in filename.
# @param content The content to place in the file.
# @param source A source to obtain the file content from.
# @param prefix
#   Prefix of file name to be created, if left as `file-` it will be
#   auto included in the main nft configuration
#
define nftables::file (
  String[1] $label = $title,
  Optional[String] $content = undef,
  Optional[Variant[String,Array[String,1]]] $source = undef,
  String $prefix = 'file-',
) {
  if $content and $source {
    fail('Please pass only $content or $source, not both.')
  }

  $concat_name = "nftables-${name}"

  Package['nftables'] -> file { "/etc/nftables/puppet-preflight/${prefix}${label}.nft":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => $nftables::default_config_mode,
    content => $content,
    source  => $source,
  } ~> Exec['nft validate'] -> file { "/etc/nftables/puppet/${prefix}${label}.nft":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => $nftables::default_config_mode,
    content => $content,
    source  => $source,
  } ~> Service['nftables']
}
