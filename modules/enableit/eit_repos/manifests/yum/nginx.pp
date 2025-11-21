# Nginx
class eit_repos::yum::nginx (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

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
