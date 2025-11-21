# Dell yum repos
class eit_repos::yum::dell (
  Boolean               $ensure     = false,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) inherits eit_repos::yum {

  $repos = {
    'dell-system-update_dependent' => "https://linux.dell.com/repo/hardware/dsu/mirrors.cgi?osname=el\$releasever&basearch=\$basearch&native=1",
    'dell-system-update_independent' => 'https://linux.dell.com/repo/hardware/dsu/os_independent/',
  }

  $repos.each | $key, $value | {
    yumrepo { $key :
      ensure     => ensure_present($ensure),
      mirrorlist => $value,
      enabled    => 1,
      noop       => $noop_value,
      gpgcheck   => 1,
      gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update',
      descr      => $key,
    }
  }

  eit_repos::yum::gpgkey { 'dell-system-update' :
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update',
    source     => 'https://linux.dell.com/repo/pgp_pubkeys/0x1285491434D8786F.asc',
    noop_value => $noop_value,
  }
}
