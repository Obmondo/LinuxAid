#
# Configures jgroups TCP-based stacks.
#
# @param properties TCP properties hash.
#
define wildfly::jgroups::stack::tcp (
  Hash $properties,
) {
  $stack = downcase($title)

  wildfly::jgroups::stack { $stack:
    protocols => [
      $title,
      'MERGE3',
      { 'FD_SOCK' => { 'socket-binding' => 'jgroups-tcp-fd' } },
      'FD',
      'VERIFY_SUSPECT',
      'pbcast.NAKACK2',
      'UNICAST3',
      'pbcast.STABLE',
      'pbcast.GMS',
      'UFC',
      'MFC',
      'FRAG2',
      'RSVP',
    ],
    transport => {
      'TCP' => {
        'socket-binding' => 'jgroups-tcp',
      },
    },
  }
  -> wildfly::resource { "/subsystem=jgroups/stack=${stack}/protocol=${title}":
    content => $properties,
  }
  -> wildfly::resource { '/subsystem=jgroups':
    content => {
      'default-stack' => $stack,
    },
  }
}
