# EnableIT Client
class eit_repos::yum::epel (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,

  Enum['http', 'https'] $source_protocol = lookup('eit_repos::source_protocol'),
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  yumrepo { 'enableit-epel' :
    ensure   => ensure_present($ensure),
    baseurl  => "${source_protocol}://repos.obmondo.com/epel/\$releasever/\$basearch/",
    noop     => $noop_value,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever',
    descr    => 'EnableIT Repository for EPEL-$releasever',
  }

  yum::gpgkey { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}" :
    ensure => ensure_present($ensure),
    noop   => $noop_value,
    source => "puppet:///modules/eit_repos/yum/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}",
  }
}
