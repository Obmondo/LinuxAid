# Suse Openvox8
class eit_repos::zypper::openvox (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_os_major = $facts['os']['release']['major']

  zypprepo { 'obmondo_openvox8':
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/GPG-KEY-openvox-openvox8-release',
    descr    => "OpenVox8 For Repository Suse-${_os_major}",
    baseurl  => "https://repos.obmondo.com/openvox/sles/openvox8/${_os_major}/\$basearch/",
  }

  # Same key is used to sign all packages
  eit_repos::yum::gpgkey { 'obmondo_openvox8':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/GPG-KEY-openvox-openvox8-release',
    source     => 'puppet:///modules/eit_repos/yum/GPG-KEY-openvox-openvox8-release',
    noop_value => $noop_value,
  }
}
