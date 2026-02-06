# @summary Class for managing openvox installation and configuration
#
# @param version The openvox version to install. The default is the type Eit_types::Version.
#
# @param server The hostname or IP address of the openvox server.
#
# @param server_port The port number for the openvox server. Defaults to 443.
#
# @param config_file The path to the openvox configuration file. Defaults to `$facts['openvox_config']`.
#
# @param run_agent_as_noop Whether to run the openvox agent in noop mode. Defaults to true.
#
# @param extra_main_settings Optional hash of extra settings for the main openvox configuration. Defaults to undef.
#
# @param environment The openvox environment to use. Defaults to 'master'.
#
# @param package_name The package name.
#
# @param manage Whether to manage the openvox. Defaults to true.
#
# @param noop_value Boolean value for noop mode. Defaults to undef.
#
# @groups server_config server, server_port, config_file
#
# @groups agent run_agent_as_noop, noop_value
#
# @groups settings extra_main_settings, environment
#
# @groups versioning version, package_name
#
# @groups misc manage
#
class common::openvox (
  Eit_types::Version    $version,
  Stdlib::Host          $server,
  String                $package_name,
  String                $environment,
  Stdlib::Port          $server_port         = 443,
  Boolean               $manage              = true,
  Eit_types::Noop_Value $noop_value          = undef,
  Stdlib::Absolutepath  $config_file         = $facts['puppet_config'],
  Boolean               $run_agent_as_noop   = true,
  Optional[Hash]        $extra_main_settings = undef,
) {
  if $manage {
    include eit_repos 
    contain profile::openvox
  }
}
