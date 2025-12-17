#
# Configures a connection factory
#
define wildfly::messaging::activemq::connection_factory (
  $entries        = undef,
  $connectors     = undef,
  $target_profile = undef,
) {
  $params = {
    'entries'    => $entries,
    'connectors' => $connectors,
  }

  wildfly::resource { "/subsystem=messaging-activemq/server=default/connection-factory=${title}":
    content => $params,
    profile => $target_profile,
  }
}
