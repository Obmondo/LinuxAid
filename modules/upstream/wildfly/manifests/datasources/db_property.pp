#
# Configures connection property in a database
#
define wildfly::datasources::db_property(
  $database,
  $value = undef,
  $target_profile = undef) {

  $params = {
    'value' => $value,
  }

  wildfly::resource { "/subsystem=datasources/data-source=${database}/connection-properties=${title}":
    content => $params,
    profile => $target_profile,
  }

}
