# Rackslab slurm-web yum repos
class eit_repos::yum::rackslab_slurmweb (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  yumrepo { 'rackslab-slurmweb-5' :
    ensure   => ensure_present($ensure),
    baseurl  => "https://pkgs.rackslab.io/rpm/el\$releasever/slurmweb-5/\$basearch",
    enabled  => 1,
    noop     => $noop_value,
    gpgcheck => 1,
    descr    => 'Rackslab slurmweb-5',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rackslab'
  }

  eit_repos::yum::gpgkey { 'rackslab-slurmweb-5':
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-Rackslab',
    source     => 'puppet:///modules/eit_repos/yum/RPM-GPG-KEY-Rackslab-Slurmweb',
    noop_value => $noop_value,
  }
}
