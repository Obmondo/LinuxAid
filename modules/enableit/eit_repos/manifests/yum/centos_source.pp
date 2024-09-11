# CentOS Source
class eit_repos::yum::centos_source (
  Boolean $ensure               = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  package::install('centos-release')

  ['base-source', 'updates-source', 'extras-source', 'centosplus-source'].each | $repo | {
    $_repo = $repo.split('-')[0]
    $capitalize_repo = $repo.capitalize
    yumrepo { $repo :
      ensure   => ensure_present($ensure),
      baseurl  => "http://vault.centos.org/centos/$\releasever/${_repo}/Source/",
      noop     => $noop_value,
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7',
      descr    => "CentOS-\$releasever - ${capitalize_repo}",
      require  => Package['centos-release'],
    }
  }
}
