# Mariadb
class eit_repos::yum::mariadb (
  Boolean               $ensure     = true,
  String                $version    = '10.4',
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $_release = $facts['os']['name'].downcase
  $_release_mysql = if $_release == 'redhat' {
    'rhel'
  } else {
    $_release
  }

  yumrepo { 'mariadb' :
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    baseurl  => "https://yum.mariadb.org/${version}/${_release_mysql}${facts['os']['release']['major'].downcase}-amd64",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    descr    => 'MariaDB Repository',
  }
}
