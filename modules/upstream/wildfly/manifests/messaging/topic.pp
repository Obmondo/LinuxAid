#
# Configures a topic
#
define wildfly::messaging::topic($entries = undef, $target_profile = undef) {

  $params = {
    'entries' => $entries
  }

  wildfly::util::resource { "/subsystem=messaging/hornetq-server=default/jms-topic=${name}":
    content => $params,
    profile => $target_profile,
  }

}