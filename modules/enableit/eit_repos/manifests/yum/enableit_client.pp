# EnableIT Client
class eit_repos::yum::enableit_client (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

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
