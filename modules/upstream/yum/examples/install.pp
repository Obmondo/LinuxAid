if ($facts['os']['release']['major'] in [5,6,7]) {
  # https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  # https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
  # https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm
  $source = "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${facts['os']['release']['major']}.noarch.rpm"

  yum::install { 'epel-release':
    ensure => present,
    source => $source,
  }
} else {
  err("Unsupported OS release ${facts['os']['release']['major']}")
}
