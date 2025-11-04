# CentOS Debug
class eit_repos::yum::centos_debug (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  package::install('centos-release')

  ['debug'].each | $repo | {
    $capitalize_repo = $repo.capitalize
    yumrepo { $repo :
      ensure   => ensure_present($ensure),
      baseurl  => 'http://debuginfo.centos.org/7/$basearch/',
      noop     => $noop_value,
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7',
      descr    => "CentOS-\$releasever - ${capitalize_repo}",
      require  => Package['centos-release'],
    }
  }
}
