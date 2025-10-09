#
# Configures a datasource
#
define wildfly::datasources::datasource(
  $config = undef,
  $target_profile = undef) {

  $profile_path = profile_path($target_profile)

  wildfly::resource { "/subsystem=datasources/data-source=${title}":
    content => $config,
    profile => $target_profile
  }
  ->
  wildfly::cli { "Enable ${title}":
    command => "${profile_path}/subsystem=datasources/data-source=${title}:enable",
    unless  => "(result == true) of ${profile_path}/subsystem=datasources/data-source=${title}:read-attribute(name=enabled)",
  }

}
