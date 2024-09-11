#
# Configures a driver
#
define wildfly::standalone::datasources::driver($driver_name = undef, $driver_module_name = undef, $driver_xa_datasource_class_name = undef) {

  $params = {
    'driver-name' => $driver_name,
    'driver-module-name' => $driver_module_name,
    'driver-xa-datasource-class-name' => $driver_xa_datasource_class_name
  }

  wildfly::util::resource { "/subsystem=datasources/jdbc-driver=${driver_name}":
    content => $params
  }

}