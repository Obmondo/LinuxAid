# @summary Manage the systemd components of a wireguard setup
# @api private
#
define wireguard::provider::systemd (
  String[1] $interface = $title,
  Enum['present', 'absent'] $ensure = 'present',
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Optional[String[1]] $table = undef,
  Optional[Integer[0,4294967295]] $firewall_mark = undef,
  Array[Hash[String,Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]]] $addresses = [],
  Optional[String[1]] $description = undef,
  Optional[Integer[1200, 9000]] $mtu = undef,
  Array[Hash[String[1], Variant[String[1], Boolean]]] $routes = [],
  Array[Stdlib::IP::Address] $default_allowlist = [],
) {
  assert_private()

  $systemd_ensure = $ensure ? {
    'present' => 'file',
    default   => $ensure,
  }

  systemd::network { "${interface}.netdev":
    ensure          => $systemd_ensure,
    content         => epp("${module_name}/netdev.epp", {
        'interface'         => $interface,
        'dport'             => $dport,
        'table'             => $table,
        'firewall_mark'     => $firewall_mark,
        'description'       => $description,
        'mtu'               => $mtu,
        'peers'             => $peers,
        'default_allowlist' => $default_allowlist,
    }),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
    require         => File["/etc/wireguard/${interface}"],
  }

  $network_epp_params = {
    'interface'       => $interface,
    'addresses'       => $addresses,
    'routes'          => $routes,
  }

  systemd::network { "${interface}.network":
    ensure          => $systemd_ensure,
    content         => epp("${module_name}/network.epp", $network_epp_params),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
  }
}
