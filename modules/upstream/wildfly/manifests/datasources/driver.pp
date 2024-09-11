#
# Configures a driver
#
define wildfly::datasources::driver($driver_name, $driver_module_name, $driver_class_name = undef, $driver_xa_datasource_class_name = undef, $target_profile = undef) {

  $params = {
    'driver-name' => $driver_name,
    'driver-module-name' => $driver_module_name,
    'driver-class-name' => $driver_class_name,
    'driver-xa-datasource-class-name' => $driver_xa_datasource_class_name
  }

  wildfly::util::resource { "/subsystem=datasources/jdbc-driver=${driver_name}":
    content => $params,
    profile => $target_profile,
  }

}