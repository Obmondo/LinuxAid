#
# Configures a topic
#
define wildfly::messaging::topic(
  $entries,
  $target_profile = undef) {

  $params = {
    'entries' => $entries
  }

  wildfly::resource { "/subsystem=messaging/hornetq-server=default/jms-topic=${title}":
    content => $params,
    profile => $target_profile,
  }

}
