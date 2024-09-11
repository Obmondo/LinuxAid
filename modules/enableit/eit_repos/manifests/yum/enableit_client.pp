# EnableIT Client
class eit_repos::yum::enableit_client (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = false,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }
  $yumversion = $facts['os']['release']['major']
  # Obmondo Client
  yumrepo { 'obmondo-client' :
    ensure   => ensure_present($ensure),
    baseurl  => "${source_protocol}://repos.obmondo.com/packagesign/public/yum/el/${yumversion}/\$basearch/",
    noop     => $noop_value,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    descr    => 'Obmondo Custom Repository to deploy EnableIT packages',
    require  => Eit_Repos::Yum::Gpgkey['enableit_client'],
  }

  eit_repos::yum::gpgkey { 'enableit_client':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    source     => 'puppet:///modules/eit_repos/GPG-KEY-EnableIT_Aps_Ltd',
    noop_value => $noop_value,
  }
}
