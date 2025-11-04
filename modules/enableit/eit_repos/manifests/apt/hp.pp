# Manage Physical HP server
# Repo configuration
# https://downloads.linux.hpe.com/SDR/project/mcp/
class eit_repos::apt::hp (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['codename']

  apt::source { "obmondo_hp_${distro}":
    ensure   => ensure_present($ensure),
    location => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
    noop     => $noop_value,
    release  => "${distro}/current",
    repos    => 'non-free',
  }

  $extra_hp_keys = {
    'hpPublicKey2048'       => 'http://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub',
    'hpPublicKey2048_key1'  => 'http://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub',
    'hpePublicKey2048_key1' => 'http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub',
    'hpePublicKey1024'      => 'http://downloads.linux.hpe.com/SDR/hpPublicKey1024.pub',
  }

  $extra_hp_keys.each |$key, $value| {
    apt::keyring { $key :
      ensure => ensure_present($ensure),
      noop   => $noop_value,
      source => $value,
    }
  }
}
