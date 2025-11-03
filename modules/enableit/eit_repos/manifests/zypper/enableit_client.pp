# EnableIT Client
class eit_repos::zypper::enableit_client (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  $suseversion = $facts['os']['release']['major']

  # Obmondo Client
  zypprepo { 'obmondo-client':
    ensure      => ensure_present($ensure),
    baseurl     => "${source_protocol}://repos.obmondo.com/packagesign/public/yum/sles/${suseversion}/\$basearch/",
    enabled     => 1,
    autorefresh => 1,
    gpgcheck    => 1,
    noop        => $noop_value,
    gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    type        => 'rpm-md',
  }

  eit_repos::yum::gpgkey { 'enableit_client':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    source     => 'puppet:///modules/eit_repos/GPG-KEY-EnableIT_Aps_Ltd',
    noop_value => $noop_value,
  }
}
