#
# Configures connection property in a database
#
# @param database datasource database
# @param value datasource db property value
# @param target_profile for domain mode you need to set this parameter
#
define wildfly::datasources::db_property (
  String           $database,
  Optional[String] $value          = undef,
  Optional[String] $target_profile = undef,
) {
  $params = {
    'value' => $value,
  }

  wildfly::resource { "/subsystem=datasources/data-source=${database}/connection-properties=${title}":
    content => $params,
    profile => $target_profile,
  }
}
