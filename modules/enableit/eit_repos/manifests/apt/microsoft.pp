# Microsoft
class eit_repos::apt::microsoft (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_os_type = $facts['os']['name'].downcase
  $_os_major = $facts['os']['release']['major']

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  apt::source { 'microsoft-prod':
    ensure       => ensure_present($ensure),
    location     => "https://packages.microsoft.com/${_os_type}/${_os_major}/prod",
    release      => $facts['os']['distro']['codename'],
    noop         => $noop_value,
    architecture => $architecture,
    # https://learn.microsoft.com/en-us/linux/packages#how-to-use-the-gpg-repository-signing-key
    key          => {
      name   => "microsoft_${facts['os']['distro']['codename']}.asc",
      source => 'https://packages.microsoft.com/keys/microsoft.asc',
    },
    include      => {
      'src' => false,
    },
  }

}

