# Jenkins
class eit_repos::yum::jenkins (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  yumrepo { 'jenkins' :
    ensure   => ensure_present($ensure),
    baseurl  => 'http://pkg.jenkins-ci.org/redhat',
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 0,
    descr    => 'Jenkins Repository',
  }
}
