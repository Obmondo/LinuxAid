# PuppetLabs
class eit_repos::yum::puppetlabs (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # Remove the repo if puppet agent version is not 7
  $_ensure = $facts['puppetversion'] ? {
    /^7.*/ => $ensure,
    default => false
  }

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_os_major = $facts['os']['release']['major']

  # PuppetLabs
  yumrepo { "puppetlabs-puppet7":
    ensure   => ensure_present($_ensure),
    noop     => $noop_value,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-inc-release-key',
    descr    => "PuppetLabs ${version} Products El \$releasever - \$basearch",
    baseurl  => "https://repos.obmondo.com/puppetlabs/yum/puppet7/el/${_os_major}/\$basearch/",
    target   => "/etc/yum.repos.d/puppetlabs-puppet7.repo",
  }
  # Same key is used to sign all packages
  eit_repos::yum::gpgkey { 'puppetlabs-puppet7':
    ensure     => ensure_present($_ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-inc-release-key',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-puppet-inc-release-key',
    noop_value => $noop_value,
  }
}

