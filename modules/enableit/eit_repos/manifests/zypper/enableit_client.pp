# EnableIT Client
class eit_repos::zypper::enableit_client (
  Boolean               $ensure          = true,
  Optional[Boolean]     $noop_value      = false,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $suseversion = $facts['os']['release']['major']

  # Obmondo Client
  zypprepo { 'obmondo-client':
    ensure      => ensure_present($ensure),
    baseurl     => "${source_protocol}://repos.obmondo.com/packagesign/public/yum/sles/${suseversion}/\$basearch/",
    enabled     => 1,
    autorefresh => 1,
    gpgcheck    => 1,
    noop        => $noop_value,
    type        => 'rpm-md',
  }

  eit_repos::yum::gpgkey { 'enableit_client':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    source     => 'puppet:///modules/eit_repos/GPG-KEY-EnableIT_Aps_Ltd',
    noop_value => $noop_value,
  }
}
