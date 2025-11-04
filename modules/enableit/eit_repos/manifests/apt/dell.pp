# Dell APT repos
class eit_repos::apt::dell (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) inherits eit_repos::apt {

  $distro = $facts['os']['distro']['codename']

  if $facts['os']['distro']['id'] == 'Ubuntu' {
    apt::source { 'dell-system-update':
      ensure   => ensure_present($ensure),
      location => "http://linux.dell.com/repo/community/openmanage/11010/${distro}/",
      noop     => $noop_value,
      key      => {
        name   => "ubuntu_${distro}_dell.asc",
        source => 'https://linux.dell.com/repo/pgp_pubkeys/0x1285491434D8786F.asc',
      },
    }
  }
}
