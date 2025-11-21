# CentOS Plus
class eit_repos::yum::centos_plus (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  package::install('centos-release')

  ['centosplus'].each | $repo | {
    $capitalize_repo = $repo.capitalize
    yumrepo { $repo :
      ensure     => ensure_present($ensure),
      mirrorlist => "http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=${repo}",
      noop       => $noop_value,
      enabled    => 1,
      gpgcheck   => 1,
      gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7',
      descr      => "CentOS-\$releasever - ${capitalize_repo}",
      require    => Package['centos-release'],
    }
  }
}
