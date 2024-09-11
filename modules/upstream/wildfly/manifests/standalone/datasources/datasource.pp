#
# Configures a datasource
#
define wildfly::standalone::datasources::datasource($config = undef) {

  wildfly::util::resource { "/subsystem=datasources/data-source=${name}":
    content => $config,
  }
  ->
  wildfly::util::exec_cli { "Enable ${name}":
    command => "/subsystem=datasources/data-source=${name}:enable",
    unless  => "(result == true) of /subsystem=datasources/data-source=${name}:read-attribute(name=enabled)"
  }

}