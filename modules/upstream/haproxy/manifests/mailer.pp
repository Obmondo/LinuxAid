# @summary
#   This type will set up a mailer entry inside the mailers configuration block in
#   haproxy.cfg on the load balancer. 
#
# @note
#   Currently, it has the ability to
#   specify the instance name, ip address, ports and server_names.
#   Automatic discovery of mailer nodes may be implemented by exporting the mailer
#   resource for all HAProxy balancer servers that are configured in the same HA
#   block and then collecting them on all load balancers.
#
#
# @param mailers_name
#  Specifies the mailer in which this load balancer needs to be added.
#
# @param server_names
#  Sets the name of the mailer server in the mailers configuration block.
#   Defaults to the hostname. Can be an array. If this parameter is
#   specified as an array, it must be the same length as the
#   ipaddresses parameter's array. A mailer is created for each pair
#   of server\_names and ipaddresses in the array.
#
# @param ipaddresses
#  Specifies the IP address used to contact the mailer member server.
#   Can be an array. If this parameter is specified as an array it
#   must be the same length as the server\_names parameter's array.
#   A mailer is created for each pair of address and server_name.
#
# @param port
#  Sets the port on which the mailer is going to share the state.
#
# @param instance
#  The instance name of the mailer entry. Default value: 'haproxy'.
#
define haproxy::mailer (
  String                        $mailers_name,
  Variant[String, Stdlib::Port] $port,
  Variant[String[1], Array]     $server_names = $facts['networking']['hostname'],
  Variant[String, Array]        $ipaddresses  = $facts['networking']['ip'],
  String                        $instance     = 'haproxy',
) {
  include haproxy::params
  if $instance == 'haproxy' {
    $instance_name = 'haproxy'
    $config_file = $haproxy::config_file
  } else {
    $instance_name = "haproxy-${instance}"
    $config_file = inline_template($haproxy::params::config_file_tmpl)
  }

  $parameters = {
    'ipaddresses'  => $ipaddresses,
    'server_names' => $server_names,
    'port'         => $port,
  }

  # Templates uses $ipaddresses, $server_name, $ports, $option
  concat::fragment { "${instance_name}-mailers-${mailers_name}-${name}":
    order   => "40-mailers-01-${mailers_name}-${name}",
    target  => $config_file,
    content => epp('haproxy/haproxy_mailer.epp', $parameters),
  }
}
