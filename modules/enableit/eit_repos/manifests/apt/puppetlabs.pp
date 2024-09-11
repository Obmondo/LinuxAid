# Apt Puppetlabs
class eit_repos::apt::puppetlabs (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

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

  apt::source { 'obmondo_puppetlabs':
    ensure       => ensure_present($ensure),
    location     => 'https://repos.obmondo.com/puppetlabs/apt',
    release      => $facts['os']['distro']['codename'],
    architecture => $architecture,
    repos        => 'puppet7',
    include      => {
      'src' => false,
    },
    key          => {
      name   => 'obmondo_puppetlabs.asc',
      source => 'puppet:///modules/eit_repos/apt/DEB-GPG-KEY-puppet-inc-release-key',
    }
  }
}
