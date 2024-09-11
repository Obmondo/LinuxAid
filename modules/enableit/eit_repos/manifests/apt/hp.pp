# Manage Physical HP server
# Repo configuration
# https://downloads.linux.hpe.com/SDR/project/mcp/
class eit_repos::apt::hp (
  Boolean $ensure               = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  apt::source { "obmondo_hp_${::lsbdistcodename}" :
    ensure   => ensure_present($ensure),
    location => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
    noop     => $noop_value,
    release  => "${::lsbdistcodename}/current",
    repos    => 'non-free',
  }

  $extra_hp_keys = {
    '476DADAC9E647EE27453F2A3B070680A5CE2D476' => 'http://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub',
    '882F7199B20F94BD7E3E690EFADD8D64B1275EA3' => 'http://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub',
    '57446EFDE098E5C934B69C7DC208ADDE26C2B797' => 'http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub',
    'FB410E68CEDF95D066811E95527BC53A2689B887' => 'http://downloads.linux.hpe.com/SDR/hpPublicKey1024.pub',
  }

  $extra_hp_keys.each | $key, $value | {
    apt::key { $key :
      ensure => ensure_present($ensure),
      id     => $key,
      noop   => $noop_value,
      source => $value,
    }
  }
}
