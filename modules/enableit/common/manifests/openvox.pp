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
  Eit_types::Version   $version,
  Stdlib::Host         $server,
  String               $package_name,
  Stdlib::Port         $server_port         = 443,
  Boolean              $manage              = true,
  Optional[Boolean]    $noop_value          = undef,
  Stdlib::Absolutepath $config_file         = $facts['puppet_config'],
  Boolean              $run_agent_as_noop   = true,
  Optional[Hash]       $extra_main_settings = undef,

  # TODO: lets control via enc script
  String               $environment         = 'master',
) {

  $_arch    = profile::arch()
  $_os_name = $facts['os']['name']
  $_kernel  = $facts['kernel'].downcase

  archive { 'linuxaid-cli':
    ensure       => present,
    source       => "https://github.com/Obmondo/Linuxaid-cli/releases/download/v${version}/linuxaid-cli_Linux_${_arch}.tar.gz",
    extract      => true,
    path         => "/tmp/linuxaid-cli_Linux_${_arch}.tar.gz",
    extract_path => '/usr/bin',
    cleanup      => true,
    user         => 'root',
    group        => 'root',
    noop         => $noop_value,
  }

  ensure_resource('file', '/etc/default', {
    ensure => directory,
    noop   => $noop_value,
    mode   => '0755',
    owner  => 'root',
  })

  file { '/etc/default/linuxaid-cli':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    noop    => $noop_value,
    content => anything_to_ini({
      'PUPPETCERT'    => $facts['hostcert'],
      'PUPPETPRIVKEY' => $facts['hostprivkey'],
      'HOSTNAME'      => $facts['networking']['hostname'],
    }),
  }

  if $manage {
    contain profile::openvox
  }
}
