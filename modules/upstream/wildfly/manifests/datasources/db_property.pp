#
# Configures connection property in a database
#
define wildfly::datasources::db_property($database = undef, $value = undef,  $target_profile = undef) {
  
  $params = {
    'value' => $value,
  }

  wildfly::util::resource { "/subsystem=datasources/data-source=${database}/connection-properties=${name}":
    content => $params,
    profile => $target_profile,
  }

}
