# Microsoft
class eit_repos::yum::microsoft (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $_os_major = $facts['os']['release']['major']

  yumrepo { 'microsoft-prod' :
    ensure   => ensure_present($ensure),
    baseurl  => "https://packages.microsoft.com/rhel/${_os_major}/prod/",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    descr    => 'Microsoft Repository',
    gpgkey   => 'file:////etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod'
  }

  eit_repos::yum::gpgkey { 'microsoft-prod':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod',
    source     => 'https://packages.microsoft.com/keys/microsoft.asc',
    noop_value => $noop_value,
  }

}
