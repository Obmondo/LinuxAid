# Jenkins
class eit_repos::yum::jenkins (
  Boolean $ensure               = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  yumrepo { 'jenkins' :
    ensure   => ensure_present($ensure),
    baseurl  => 'http://pkg.jenkins-ci.org/redhat',
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 0,
    descr    => 'Jenkins Repository',
  }
}
