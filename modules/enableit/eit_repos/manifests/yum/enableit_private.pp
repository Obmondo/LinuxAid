# EnableIT Private Repo
# Only for enableit server
class eit_repos::yum::enableit_private (
  Boolean $ensure               = false,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  yumrepo { 'base' :
    ensure   => ensure_present($ensure),
    baseurl  => "${source_protocol}://repos.obmondo.com/centos/\$releasever/os/\$basearch/",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$releasever',
    descr    => 'EnableIT Repository for CentOS-$releasever - Base',
  }

  yumrepo { 'updates' :
    ensure   => ensure_present($ensure),
    baseurl  => "${source_protocol}://repos.obmondo.com/centos/\$releasever/updates/\$basearch/",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$releasever',
    descr    => 'EnableIT Repository for CentOS-$releasever - Base',
  }

  yumrepo { 'obmondo-private' :
    ensure   => ensure_present($ensure),
    baseurl  => "${source_protocol}://repos.obmondo.com/packagesign/internal/yum/el/\$releasever/\$basearch/",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EnableIT_Aps_Ltd',
    descr    => 'Obmondo Custom Private Repository to deploy EnableIT packages'
  }

  yumrepo { 'obmondo-client-extra':
    ensure => absent,
    noop   => $noop_value,
  }

  yum::gpgkey { "/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${facts['os']['release']['major']}" :
    ensure => ensure_present($ensure),
    noop   => $noop_value,
    source => "puppet:///modules/eit_repos/yum/RPM-GPG-KEY-CentOS-${facts['os']['release']['major']}",
  }
}
