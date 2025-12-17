#
# Configures a tcpping stack.
#
# @param initial_hosts Comma delimited list of hosts to be contacted for initial membership.
# @param num_initial_members Number of initial members.
# @param timeout Max time for socket creation. Default is 3000 msec.
# @param port_range Number of additional ports to be probed for membership.
#                   A port_range of 0 does not probe additional ports.
#                   Example: initial_hosts=A[7800] port_range=0 probes A:7800, port_range=1 probes A:7800 and A:7801.
#
define wildfly::jgroups::stack::tcpping (
  String  $initial_hosts,
  Integer $num_initial_members,
  Integer $timeout    = 3000,
  Integer $port_range = 0,
) {
  $properties = {
    'properties' => {
      'initial_hosts'       => $initial_hosts,
      'timeout'             => $timeout,
      'num_initial_members' => $num_initial_members,
      'port_range'          => $port_range,
    },
  }

  wildfly::jgroups::stack::tcp { 'TCPPING':
    properties => $properties,
  }
}
