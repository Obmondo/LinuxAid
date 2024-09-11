# Fwupd
class profile::software::fwupd (
  Boolean           $enable     = $common::software::fwupd::enable,
  Optional[Boolean] $noop_value = $common::software::fwupd::noop_value,
) {

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  $packages = if $facts['os']['family'] == 'Debian' {
                ['fwupd', 'fwupd-signed']
              }
              else {
                ['fwupd']
              }

  package { $packages :
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

# Since fwupd-refresh is not there in redhat7 so skiping the service there.

  if $facts.dig('os', 'release', 'major') != '7' {
    service { 'fwupd-refresh.timer':
      ensure  => ensure_service($enable),
      noop    => $noop_value,
      require => Package[$packages],
    }
  }
}
