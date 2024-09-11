# @summary
#  Install the Debian apt repository for opensearch.
#
# @api private
#
class opensearch::repository::debian {
  assert_private()

  $location = $opensearch::version =~ Undef ? {
    true  => pick($opensearch::repository_location, 'https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt'),
    false => pick($opensearch::repository_location, "https://artifacts.opensearch.org/releases/bundle/opensearch/${opensearch::version[0]}.x/apt"),
  }

  archive { '/tmp/opensearch.pgp':
    ensure          => $opensearch::repository_ensure,
    source          => $opensearch::repository_gpg_key,
    extract         => true,
    extract_path    => '/usr/share/keyrings',
    extract_command => 'gpg --dearmor < %s > opensearch.keyring.gpg',
    creates         => '/usr/share/keyrings/opensearch.keyring.gpg',
  }

  apt::source { 'opensearch':
    ensure   => $opensearch::repository_ensure,
    location => $location,
    release  => 'stable',
    repos    => 'main',
    keyring  => '/usr/share/keyrings/opensearch.keyring.gpg',
  }

  include apt

  if $opensearch::manage_package {
    Apt::Source['opensearch'] ~> Exec['apt_update'] -> Package['opensearch']
  } else {
    Apt::Source['opensearch'] ~> Exec['apt_update']
  }
}
