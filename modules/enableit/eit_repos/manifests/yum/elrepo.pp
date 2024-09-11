# ELrepo
class eit_repos::yum::elrepo (
  Boolean $ensure               = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }
  # TODO: Looks like it support only centos6, get it working for centos7
  yumrepo { 'elrepo' :
    ensure     => ensure_present($ensure),
    baseurl    => "${::eit_repos::source_protocol}://elrepo.org/linux/elrepo/el6/\$basearch/",
    mirrorlist => "${::eit_repos::source_protocol}://elrepo.org/mirrors-elrepo.el6",
    noop       => $noop_value,
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org',
    descr      => "ELRepo.org Community Enterprise Linux Repository - el${facts['os']['release']['major']}",
  }
  yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org' :
    ensure => ensure_present($ensure),
    noop   => $noop_value,
    source => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-elrepo.org'
  }
}
