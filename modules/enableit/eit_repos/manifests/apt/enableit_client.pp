# Apt enableit_client
# This class is for obmondo clients
class eit_repos::apt::enableit_client (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = false,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  File {
    noop => $noop_value,
  }

  # This file is installed by the install script; remove it now to avoid
  # warnings -- we manage the repo in another file.
  file { '/etc/apt/sources.list.d/obmondo.list':
    ensure => 'absent',
    noop   => $noop_value,
  }

  file { "/etc/obmondo/apt/obmondo_custom_${facts['os']['distro']['codename']}_key":
    ensure => absent,
    noop   => $noop_value,
  }

  apt::source { "obmondo_custom_${facts['os']['distro']['codename']}" :
    ensure       => ensure_present($ensure),
    location     => 'https://repos.obmondo.com/packagesign/public/apt',
    architecture => $architecture,
    release      => $facts['os']['distro']['codename'],
    repos        => 'main',
    include      => {
      'src' => false,
    },
    key          => {
      name   => "obmondo_custom_public_${facts['os']['distro']['codename']}.asc",
      source => 'puppet:///modules/eit_repos/GPG-KEY-EnableIT_Aps_Ltd',
    }
  }
}
