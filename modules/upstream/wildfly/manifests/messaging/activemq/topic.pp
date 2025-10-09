#
# Configures a topic
#
define wildfly::messaging::activemq::topic(
  $entries,
  $target_profile = undef) {

  $params = {
    'entries' => $entries
  }

  wildfly::resource { "/subsystem=messaging-activemq/server=default/jms-topic=${title}":
    content => $params,
    profile => $target_profile,
  }

}

