#
# Configures a xa_datasource
#
# @param config xa_datasource config
# @param target_profile for domain mode you need to set this parameter
#
define wildfly::datasources::xa_datasource (
  Optional[Hash]   $config         = undef,
  Optional[String] $target_profile = undef,
) {
  $profile_path = wildfly::profile_path($target_profile)

  wildfly::resource { "/subsystem=datasources/xa-data-source=${title}":
    content   => $config,
    recursive => true,
    profile   => $target_profile,
  }

  -> wildfly::cli { "Enable ${title}":
    command => "${profile_path}/subsystem=datasources/xa-data-source=${title}:enable",
    unless  => "(result == true) of ${profile_path}/subsystem=datasources/xa-data-source=${title}:read-attribute(name=enabled)",
  }
}
