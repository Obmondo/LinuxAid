# NI_VISA currently only used by GN
class eit_repos::yum::ni_visa (
  Boolean               $ensure     = true,
  Optional[String]      $version    = '2019.07'
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  yumrepo { 'ni-software':
    ensure        => ensure_present($ensure),
    noop          => $noop_value,
    baseurl       => "https://download.ni.com/ni-linux-desktop/${version}/rpm/ni/el\$releasever",
    enabled       => 1,
    gpgcheck      => 0,
    repo_gpgcheck => 1,
    gpgkey        => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-natinst-ni-linux-desktop-2019',
    descr         => 'NI Linux Desktop Software',
  }

  eit_repos::yum::gpgkey { 'ni-gpg-key':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-natinst-ni-linux-desktop-2019',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-natinst-ni-linux-desktop-2019',
    noop_value => $noop_value,
    before     => Yumrepo['ni-software'],
  }

}
