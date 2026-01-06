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
    contain profile::openvox
  }
}
