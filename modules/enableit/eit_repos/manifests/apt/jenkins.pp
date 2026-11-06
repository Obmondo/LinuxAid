# Jenkins LTS
class eit_repos::apt::jenkins (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = undef,
) {

  apt::source { 'jenkins':
    ensure   => ensure_present($ensure),
    noop     => $noop_value,
    location => 'https://pkg.jenkins.io/debian-stable',
    # Flat repo: a release ending in '/' is used as-is, without components.
    release  => 'binary/',
    include  => {
      'src' => false,
    },
    keyring  => '/etc/apt/keyrings/jenkins.asc',
  }

  # jenkins.io-2026.key, valid until 2028-12-21
  apt::keyring { 'jenkins.asc':
    ensure => ensure_present($ensure),
    noop   => $noop_value,
    source => 'puppet:///modules/eit_repos/apt/GPG-KEY-jenkins.asc',
  }
}
