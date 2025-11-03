# @summary Class for managing Puppet installation and configuration
#
# @param version The Puppet version to install. The default is the type Eit_types::Version.
#
# @param server The hostname or IP address of the Puppet server.
#
# @param server_port The port number for the Puppet server. Defaults to 443.
#
# @param configure_agent Whether to configure the Puppet agent. Defaults to true.
#
# @param setup_agent Whether to set up the Puppet agent. Defaults to true.
#
# @param config_file The path to the Puppet configuration file. Defaults to `$facts['puppet_config']`.
#
# @param run_agent_as_noop Whether to run the Puppet agent in noop mode. Defaults to true.
#
# @param extra_main_settings Optional hash of extra settings for the main Puppet configuration. Defaults to undef.
#
# @param environment The Puppet environment to use. Defaults to 'master'.
#
class common::puppet (
  Eit_types::Version   $version,
  Stdlib::Host         $server,
  String               $package_name,
  Stdlib::Port         $server_port         = 443,
  Boolean              $configure_agent     = true,
  Boolean              $setup_agent         = true,
  Boolean              $noop_value          = true,
  Stdlib::Absolutepath $config_file         = $facts['puppet_config'],
  Boolean              $run_agent_as_noop   = true,
  Optional[Hash]       $extra_main_settings = undef,

  # TODO: lets control via enc script
  String               $environment         = 'master',
) {
  profile::puppet.contain

  # Few nodes are still on el6
  if $facts['init_system'] == 'systemd' {
    contain ::common::puppet::clientbucket
  }

  contain ::profile::puppet::run_puppet
}
