# PuppetLabs
class eit_repos::zypper::puppetlabs (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
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

  $suseversion = $facts['os']['release']['major']

  # Obmondo Puppetlabs Repo
  zypprepo { "obmondo_puppetlabs7":
    ensure      => ensure_present($_ensure),
    name        => "obmondo_puppetlabs7",
    baseurl     => "${source_protocol}://repos.obmondo.com/puppetlabs/sles/puppet7/${suseversion}/\$basearch/",
    enabled     => 1,
    autorefresh => 1,
    gpgcheck    => 1,
    type        => 'rpm-md',
  }

  eit_repos::yum::gpgkey { 'obmondo_puppetlabs':
    ensure     => ensure_present($_ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    source     => 'https://repos.obmondo.com/puppetlabs/public.key',
    noop_value => $noop_value,
  }
}
