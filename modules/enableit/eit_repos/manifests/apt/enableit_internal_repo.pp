# Apt enableit_private
# This class is only for enableit server
class eit_repos::apt::enableit_internal_repo (
  Boolean           $ensure        = true,
  Optional[Boolean] $noop_value    = undef,
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

  apt::source { "obmondo_private_${::lsbdistcodename}" :
    ensure       => ensure_present($ensure),
    location     => 'https://repos.obmondo.com/packagesign/internal/apt',
    noop         => $noop_value,
    architecture => $architecture,
    release      => $::lsbdistcodename,
    repos        => 'main',
    include      => {
      'src' => false,
    },
  }

}
