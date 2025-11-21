# Docket yum repos
class eit_repos::yum::docker (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  # The dockerrepo only provides "centos" (not rhel) as distribution.
  # https://access.redhat.com/discussions/6249651

  yumrepo { 'docker-ce-stable' :
    ensure   => ensure_present($ensure),
    baseurl  => "https://download.docker.com/linux/centos/\$releasever/\$basearch/stable",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    descr    => 'Docker CE Stable',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-docker-ce-stable'
  }

  eit_repos::yum::gpgkey { 'docker-ce-stable':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-docker-ce-stable',
    source     => 'https://download.docker.com/linux/centos/gpg',
    noop_value => $noop_value,
  }
}
