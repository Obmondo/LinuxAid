# Mariadb
class eit_repos::yum::mariadb (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
  String            $version    = '10.4',
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_release = $facts.dig('os', 'name').downcase
  $_release_mysql = if $_release == 'redhat' {
    'rhel'
  } else {
    $_release
  }

  yumrepo { 'mariadb' :
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    baseurl  => "https://yum.mariadb.org/${version}/${_release_mysql}${facts.dig('os', 'release', 'major').downcase}-amd64",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    descr    => 'MariaDB Repository',
  }
}
