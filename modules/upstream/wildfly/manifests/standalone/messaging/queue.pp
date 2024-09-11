#
# Configures a queue
#
define wildfly::standalone::messaging::queue($durable = undef, $entries = undef, $selector = undef) {

  $params = {
    'durable' => $durable,
    'entries' => $entries,
    'selector' => $selector
  }

  wildfly::util::resource { "/subsystem=messaging/hornetq-server=default/jms-queue=${name}":
    content => $params
  }

}