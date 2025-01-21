# Zypper Microsoft
class eit_repos::zypper::microsoft (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  $suseversion = $facts['os']['release']['major']

  zypprepo { 'microsoft-prod':
    ensure      => ensure_present($ensure),
    baseurl     => "https://packages.microsoft.com/sles/${suseversion}/prod/",
    enabled     => 1,
    autorefresh => 1,
    gpgcheck    => 1,
    type        => 'rpm-md',
    noop        => $noop_value,
    gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod',
  }

  eit_repos::yum::gpgkey { 'microsoft-prod':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod',
    source     => 'https://packages.microsoft.com/keys/microsoft.asc',
    noop_value => $noop_value,
  }
}
