#
# Configures a topic
#
define wildfly::standalone::messaging::topic($entries = undef) {

  $params = {
    'entries' => $entries
  }

  wildfly::util::resource { "/subsystem=messaging/hornetq-server=default/jms-topic=${name}":
    content => $params
  }

}