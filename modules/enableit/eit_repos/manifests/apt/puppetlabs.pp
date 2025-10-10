# Apt Puppetlabs
class eit_repos::apt::puppetlabs (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # Remove the repo if puppet agent version is not 7
  $_ensure = $facts['puppetversion'] ? {
    /^7.*/ => $ensure,
    default => false
  }

    # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  File {
    noop => $noop_value,
  }

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  apt::source { 'obmondo_puppetlabs_7':
    ensure       => ensure_present($_ensure),
    location     => 'https://repos.obmondo.com/puppetlabs/apt',
    release      => $facts['os']['distro']['codename'],
    architecture => $architecture,
    repos        => 'puppet7',
    include      => {
      'src' => false,
    },
    keyring      => '/etc/apt/keyrings/obmondo_puppetlabs.asc',
  }

  apt::keyring { 'obmondo_puppetlabs.asc':
    ensure => ensure_present($_ensure),
    source => 'puppet:///modules/eit_repos/apt/DEB-GPG-KEY-puppet-inc-release-key',
    noop   => $noop_value,
  }
}
