# Microsoft
class eit_repos::yum::microsoft (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_os_major = $facts.dig('os', 'release', 'major')

  yumrepo { 'microsoft-prod' :
    ensure   => ensure_present($ensure),
    baseurl  => "https://packages.microsoft.com/rhel/${_os_major}/prod/",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    descr    => 'Microsoft Repository',
    gpgkey   => 'file:////etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod'
  }

  eit_repos::yum::gpgkey { 'microsoft-prod':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-microsoft-prod',
    source     => 'https://packages.microsoft.com/keys/microsoft.asc',
    noop_value => $noop_value,
  }

}
