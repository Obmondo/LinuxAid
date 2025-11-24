# Apt openvox
class eit_repos::apt::openvox (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  File {
    noop => $noop_value,
  }

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  $_os_type = $facts['os']['name'].downcase
  $_os_major = $facts['os']['release']['major']

  apt::source { 'obmondo_openvox8':
    ensure       => ensure_present($ensure),
    location     => 'https://repos.obmondo.com/openvox/apt',
    release      => "${_os_type}${_os_major}",
    architecture => $architecture,
    repos        => 'openvox8',
    include      => {
      'src' => false,
    },
    keyring      => '/etc/apt/keyrings/obmondo_openvox.asc',
  }

  apt::keyring { 'obmondo_openvox.asc':
    ensure => ensure_present($ensure),
    source => 'puppet:///modules/eit_repos/apt/GPG-KEY-openvox.pub',
  }
}
