# Docker sles repos
class eit_repos::zypper::dell (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) inherits eit_repos::zypper {

  if $facts['os']['release']['major'] == 15 { $dsu = 'dsu' } else { $dsu = 'DSU_19.12.02' }
  $distro = "sles${facts['os']['release']['major']}"

  $repos = {
    'dell-system-update_dependent' => "http://linux.dell.com/repo/hardware/${dsu}/mirrors.cgi/osname=${distro}&basearch=\$basearch&native=1&redirpath=/",
    'dell-system-update_independent' => "https://linux.dell.com/repo/hardware/${dsu}/os_independent/",
  }

  $repos.each | $key, $value | {
    zypprepo { $key:
      ensure      => ensure_present($ensure),
      baseurl     => $value,
      enabled     => 1,
      autorefresh => 1,
      gpgcheck    => 1,
      gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update',
      noop        => $noop_value,
    }
  }

  eit_repos::yum::gpgkey { 'dell-system-update' :
    ensure     => ensure_present($ensure),
    path       => '/etc/pki/rpm-gpg/RPM-GPG-KEY-dell-system-update',
    source     => 'https://linux.dell.com/repo/pgp_pubkeys/0x756ba70b1019ced6.asc',
    noop_value => $noop_value,
  }
}
