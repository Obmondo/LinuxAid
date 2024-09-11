class dnsmasq::config {
  file { $dnsmasq::params::config_file:
    owner        => 'root',
    group        => 0,
    mode         => '0644',
    validate_cmd => '/usr/sbin/dnsmasq --test --conf-file=%',
    source       => 'puppet:///modules/dnsmasq/dnsmasq.conf',
  }
}
