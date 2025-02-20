# Puppet installation
class common::puppet (
  Eit_types::Version   $version,
  Stdlib::Host         $server              = "${::obmondo['customer_id']}.puppet.obmondo.com", #lint:ignore:top_scope_facts
  Stdlib::Port         $server_port         = 443,
  Boolean              $configure_agent     = true,
  Boolean              $setup_agent         = true,
  Stdlib::Absolutepath $config_file         = $facts['puppet_config'],
  Boolean              $run_agent_as_noop   = true,
  Optional[Hash]       $extra_main_settings = undef,

  # TODO: lets control via enc script
  String               $environment         = 'master',
) {
  profile::puppet.contain

  # Few nodes is still on el6
  if $facts['init_system'] == 'systemd' {
    contain ::common::puppet::clientbucket
  }

  contain ::profile::puppet::run_puppet
}
