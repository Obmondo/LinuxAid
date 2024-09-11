# Nginx
class eit_repos::yum::nginx (
  Boolean $ensure               = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  yumrepo { 'nginx' :
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    baseurl  => 'http://nginx.org/packages/centos/$releasever/$basearch/',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'http://nginx.org/keys/nginx_signing.key',
    priority => 1,
    descr    => "Nginx Repository - el${facts['os']['release']['major']}",
  }
}
