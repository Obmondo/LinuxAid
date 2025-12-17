#
# Configures a driver
#
# @param driver_name datasource driver
# @param driver_module_name datasource driver module name
# @param driver_class_name datasource driver class name
# @param driver_xa_datasource_class_name datasource driver xa class name
# @param target_profile for domain mode you need to set this parameter
#
define wildfly::datasources::driver (
  String           $driver_name,
  String           $driver_module_name,
  Optional[String] $driver_class_name               = undef,
  Optional[String] $driver_xa_datasource_class_name = undef,
  Optional[String] $target_profile                  = undef,
) {
  $params = {
    'driver-name'                     => $driver_name,
    'driver-module-name'              => $driver_module_name,
    'driver-class-name'               => $driver_class_name,
    'driver-xa-datasource-class-name' => $driver_xa_datasource_class_name,
  }

  wildfly::resource { "/subsystem=datasources/jdbc-driver=${driver_name}":
    content => $params,
    profile => $target_profile,
  }
}
