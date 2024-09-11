# = Class perforce::repository
#
# == Description
# install and configure the Perforce package repository
#
class perforce::repository {

  $_gpg_key = if $perforce::rpm_gpg_key_url {
    $perforce::rpm_gpg_key_url
  } else {
    $_gpg_key_path = '/etc/pki/rpm-gpg/RPM-GPG-KEY-perforce.pub'

    file { $_gpg_key_path:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/perforce/${_gpg_key_path.basename}",
      before => Yumrepo['perforce'],
    }

    "file://${_gpg_key_path}"
  }

  yumrepo { 'perforce':
    descr    => 'Perforce Repository',
    baseurl  => "https://package.perforce.com/yum/rhel/${::os['release']['major']}/x86_64",
    gpgkey   => $_gpg_key,
    gpgcheck => true,
    enabled  => true,
  }
}
