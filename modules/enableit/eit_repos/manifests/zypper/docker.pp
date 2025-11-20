# Docker sles repos
class eit_repos::zypper::docker (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  if $facts['os']['release']['major'] == 15 {
    zypprepo { 'docker-ce-stable':
      ensure      => ensure_present($ensure),
      baseurl     => "https://download.docker.com/linux/sles/15/\$basearch/stable",
      enabled     => 1,
      autorefresh => 1,
      gpgcheck    => 1,
      noop        => $noop_value,
      gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-docker-ce-stable',
    }

    eit_repos::yum::gpgkey { 'docker-ce-stable':
      ensure     => ensure_present($ensure),
      path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-docker-ce-stable',
      source     => 'https://download.docker.com/linux/sles/gpg',
      noop_value => $noop_value,
    }
  }
}
