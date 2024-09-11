define dnsmasq::conf (
  Enum['absent', 'present']           $ensure  = 'present',
  Variant[Integer[0, 999], String[1]] $prio    = 10,
  Optional[String[1]]                 $source  = undef,
  Optional[String[1]]                 $content = undef
) {
  include dnsmasq

  file { "${dnsmasq::params::config_dir}${prio}-${name}":
    ensure       => $ensure,
    owner        => 'root',
    group        => 0,
    content      => $content,
    source       => $source,
    validate_cmd => '/usr/sbin/dnsmasq --test --conf-file=%',
    notify       => Class['dnsmasq::service'],
  }
}
