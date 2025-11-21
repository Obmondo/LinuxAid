# PuppetLabs
class eit_repos::yum::puppetlabs (
  Boolean               $ensure     = false,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $_os_major = $facts['os']['release']['major']

  # PuppetLabs
  [7, 8].each |$version| {
    yumrepo { "puppetlabs-puppet${version}":
      ensure   => ensure_present($ensure),
      noop     => $noop_value,
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-inc-release-key',
      descr    => "PuppetLabs Products El \$releasever - \$basearch",
      baseurl  => "https://repos.obmondo.com/puppetlabs/yum/puppet${version}/el/${_os_major}/\$basearch/",
      target   => "/etc/yum.repos.d/puppetlabs-puppet${version}.repo",
    }
    # Same key is used to sign all packages
    eit_repos::yum::gpgkey { "puppetlabs-puppet${version}":
      ensure     => ensure_present($ensure),
      path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-inc-release-key',
      source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-puppet-inc-release-key',
      noop_value => $noop_value,
    }
  }
}

