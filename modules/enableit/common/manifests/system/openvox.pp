# @summary Class for managing openvox installation and configuration
#
# @param version The openvox version to install. The default is the type Eit_types::Version.
#
# @param server The hostname or IP address of the openvox server.
#
# @param extra_main_settings Optional hash of extra settings for the main openvox configuration. Defaults to undef.
#
# @param environment The openvox environment to use. Defaults to 'master'.
#
# @param package_name The package name.
#
# @param noop_value Boolean value for noop mode. Defaults to undef.
#
# @groups server_config server
#
# @groups agent noop_value
#
# @groups settings extra_main_settings, environment
#
# @groups versioning version, package_name
#
class common::system::openvox (
  Eit_types::Version    $version,
  Stdlib::Host          $server,
  String                $package_name,
  String                $environment,
  Eit_types::Noop_Value $noop_value          = undef,
  Optional[Hash]        $extra_main_settings = undef,
) {
  contain profile::system::openvox
}
