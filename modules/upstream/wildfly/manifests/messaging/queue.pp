#
# Configures a queue
#
define wildfly::messaging::queue($durable = undef, $entries = undef, $selector = undef, $target_profile = undef) {

  $params = {
    'durable' => $durable,
    'entries' => $entries,
    'selector' => $selector
  }

  wildfly::util::resource { "/subsystem=messaging/hornetq-server=default/jms-queue=${name}":
    content => $params,
    profile => $target_profile,
  }

}