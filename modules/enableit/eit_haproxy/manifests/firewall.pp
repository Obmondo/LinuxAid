# Haproxy firewall module
class eit_haproxy::firewall(
  Hash[
    Eit_types::IP,
    Array[
      Variant[
        Stdlib::Port,
        Eit_types::Network::PortRange,
      ],
    ]] $firewall = $::eit_haproxy::firewall,
) {

  $firewall.each |$_ipaddress, $_ports| {
    $_ports_string = if type($_ports) =~ Type[Array] {
      join($_ports, ' ')
    } else {
      $_ports
    }

    # Firewall rules
    ensure_resource('firewall', "${_ports_string} allow haproxy_${_ipaddress}", {
      proto  => 'tcp',
      dport  => $_ports,
      jump => 'accept'
    })
  }
}
