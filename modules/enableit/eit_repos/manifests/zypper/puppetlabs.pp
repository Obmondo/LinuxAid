# PuppetLabs
class eit_repos::zypper::puppetlabs (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $suseversion = $facts['os']['release']['major']

  # Obmondo Puppetlabs Repo
  [7, 8].each |$version| {
    zypprepo { "obmondo_puppetlabs${version}":
      ensure      => ensure_present($ensure),
      name        => "obmondo_puppetlabs${version}",
      baseurl     => "${source_protocol}://repos.obmondo.com/puppetlabs/sles/puppet${version}/${suseversion}/\$basearch/",
      enabled     => 1,
      autorefresh => 1,
      gpgcheck    => 1,
      type        => 'rpm-md',
    }
  }

  eit_repos::yum::gpgkey { 'obmondo_puppetlabs':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    source     => 'https://repos.obmondo.com/puppetlabs/public.key',
    noop_value => $noop_value,
  }
}
