#
# Configures a datasource
#
# @param config datasource config
# @param target_profile for domain mode you need to set this parameter
#
define wildfly::datasources::datasource (
  Optional[Hash]   $config         = undef,
  Optional[String] $target_profile = undef,
) {
  $profile_path = wildfly::profile_path($target_profile)

  wildfly::resource { "/subsystem=datasources/data-source=${title}":
    content => $config,
    profile => $target_profile,
  }
  -> wildfly::cli { "Enable ${title}":
    command => "${profile_path}/subsystem=datasources/data-source=${title}:enable",
    unless  => "(result == true) of ${profile_path}/subsystem=datasources/data-source=${title}:read-attribute(name=enabled)",
  }
}
