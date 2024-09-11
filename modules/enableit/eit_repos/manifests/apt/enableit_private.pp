# Apt enableit_private
# This class is only for enableit server
class eit_repos::apt::enableit_private (
  Boolean           $ensure        = false,
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

  $location = $architecture ? {
    'arm64' => 'https://repos.obmondo.com/ubuntu_arm64',
    default => 'https://repos.obmondo.com/ubuntu',
  }

  [
    'base',
    'updates',
    'security',
  ].each |$release_name| {
    $_release = if $release_name == 'base' { $::lsbdistcodename } else { "${::lsbdistcodename}-${release_name}" }

    apt::source { "obmondo_${release_name}_${::lsbdistcodename}" :
      ensure       => ensure_present($ensure),
      location     => $location,
      noop         => $noop_value,
      architecture => $architecture,
      release      => $_release,
      repos        => 'main restricted universe multiverse',
      key          => {
        'id'     => '630239CC130E1A7FD81A27B140976EAF437D05B5',
        'server' => 'pgp.mit.edu',
      },
      include      => {
        'src' => false,
      },
    }
  }
}
