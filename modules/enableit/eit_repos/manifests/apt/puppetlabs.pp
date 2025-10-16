# Apt Puppetlabs
class eit_repos::apt::puppetlabs (
  Boolean           $ensure     = false,
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

  [7, 8].each |$version| {
    apt::source { "obmondo_puppetlabs_${version}":
      ensure       => ensure_present($ensure),
      location     => 'https://repos.obmondo.com/puppetlabs/apt',
      release      => $facts['os']['distro']['codename'],
      architecture => $architecture,
      repos        => "puppet${version}",
      include      => {
        'src' => false,
      },
      keyring      => '/etc/apt/keyrings/obmondo_puppetlabs.asc',
    }
  }

  apt::keyring { 'obmondo_puppetlabs.asc':
    ensure => ensure_present($ensure),
    source => 'puppet:///modules/eit_repos/apt/DEB-GPG-KEY-puppet-inc-release-key',
    noop   => $noop_value,
  }
}
