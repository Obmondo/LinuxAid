#
# Configures a datasource
#
define wildfly::standalone::datasources::xa_datasource($config = undef) {

  wildfly::util::resource { "/subsystem=datasources/xa-data-source=${name}":
    content   => $config,
    recursive => true
  }
  ->
  wildfly::util::exec_cli { "Enable ${name}":
    command => "/subsystem=datasources/xa-data-source=${name}:enable",
    unless  => "(result == true) of /subsystem=datasources/xa-data-source=${name}:read-attribute(name=enabled)"
  }

}
