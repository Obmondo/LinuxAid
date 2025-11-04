# HP MCP for community OS and SPP for RHEL and SUSE
class eit_repos::yum::hp (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  $osname = $facts.dig('os','name')

  $hp_repo_name = $osname ? {
    'RedHat' => 'spp-gen10',
    'SUSE'   => 'spp-gen10',
    default  => 'mcp',
  }

  yumrepo { "HPE-${hp_repo_name}":
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    baseurl  => "http://downloads.linux.hpe.com/SDR/repo/${hp_repo_name}/${osname}/\$releasever/\$basearch/current",
    enabled  => 1,
    gpgcheck => 0,
    gpgkey   => "http://downloads.linux.hpe.com/SDR/repo/${hp_repo_name}/GPG-KEY-${hp_repo_name}",
    descr    => "name=HPE Software Delivery Repository for ${hp_repo_name}",
  }
}
