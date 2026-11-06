# Jenkins LTS
class eit_repos::yum::jenkins (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = undef,
) {

  yumrepo { 'jenkins' :
    ensure   => ensure_present($ensure),
    baseurl  => 'https://pkg.jenkins.io/rpm-stable/',
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins',
    descr    => 'Jenkins-stable',
  }

  # jenkins.io-2026.key, valid until 2028-12-21
  eit_repos::yum::gpgkey { 'jenkins':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-jenkins',
    noop_value => $noop_value,
  }
}
