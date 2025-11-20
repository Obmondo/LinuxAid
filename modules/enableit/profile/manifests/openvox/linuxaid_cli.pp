# Linuxaid-cli setup
class profile::openvox::linuxaid_cli (
  Eit_types::Version    $version    = $common::openvox::linuxaid_cli_version,
  Eit_types::Noop_Value $noop_value = undef,
) {
  $_arch    = profile::arch()
  $_os_name = $facts['os']['name']
  $_kernel  = $facts['kernel'].downcase

  archive { 'linuxaid-cli':
    ensure       => present,
    source       => "https://github.com/Obmondo/Linuxaid-cli/releases/download/v${version}/linuxaid-cli_v${version}_linux_${_arch}.tar.gz",
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
}
