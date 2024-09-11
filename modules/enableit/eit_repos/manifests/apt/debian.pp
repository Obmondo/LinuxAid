# Debian APT repos
class eit_repos::apt::debian (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['codename']

  if $facts['os']['distro']['id'] == 'Debian' {
    $repos = {
      "${distro}"          => 'https://deb.debian.org/debian',
      "${distro}-updates"  => 'https://deb.debian.org/debian',
      "${distro}-security" => 'https://security.debian.org',
    }

    $repos.each |$key, $value | {
      apt::source { $key :
        ensure   => ensure_present($ensure),
        location => $value,
        noop     => $noop_value,
        release  => $key,
        repos    => 'main contrib non-free',
      }
    }

    $apt_keys = {
      'AC530D520F2F3269F5E98313A48449044AAD5C5D' => "https://deb.debian.org/debian/dists/${distro}/Release.gpg",
      '1F89983E0081FDE018F3CC9673A4F27B8DD47936' => "https://security.debian.org/dists/${distro}-security/Release.gpg",
    }

    $apt_keys.each | $key, $value | {
      apt::key { $key :
        ensure => ensure_present($ensure),
        id     => $key,
        noop   => $noop_value,
        source => $value,
      }
    }
  }
}
