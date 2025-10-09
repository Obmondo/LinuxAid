#
# Configures a queue
#
define wildfly::messaging::queue(
  $entries = undef,
  $durable = undef,
  $selector = undef,
  $target_profile = undef) {

  $params = {
    'durable' => $durable,
    'entries' => $entries,
    'selector' => $selector
  }

  wildfly::resource { "/subsystem=messaging/hornetq-server=default/jms-queue=${title}":
    content => $params,
    profile => $target_profile,
  }

}
