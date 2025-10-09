# @summary
#  Install the Debian apt repository for OpenSearch Dashboards.
#
# @api private
#
class opensearch_dashboards::repository::debian {
  assert_private()

  $location = $opensearch_dashboards::version =~ Undef ? {
    true  => pick($opensearch_dashboards::repository_location, 'https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/apt'),
    false => pick($opensearch_dashboards::repository_location, "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${opensearch_dashboards::version[0]}.x/apt"),
  }

  archive { '/tmp/opensearch-dashboards.pgp':
    ensure          => $opensearch_dashboards::repository_ensure,
    source          => $opensearch_dashboards::repository_gpg_key,
    extract         => true,
    extract_path    => '/usr/share/keyrings',
    extract_command => 'gpg --dearmor < %s > opensearch.keyring.gpg',
    creates         => '/usr/share/keyrings/opensearch.keyring.gpg',
  }

  apt::source { 'opensearch-dashboards':
    ensure   => $opensearch_dashboards::repository_ensure,
    location => $location,
    release  => 'stable',
    repos    => 'main',
    keyring  => '/usr/share/keyrings/opensearch.keyring.gpg',
  }

  include apt

  if $opensearch_dashboards::manage_package {
    Apt::Source['opensearch-dashboards'] ~> Exec['apt_update'] -> Package['opensearch-dashboards']
  } else {
    Apt::Source['opensearch-dashboards'] ~> Exec['apt_update']
  }
}
