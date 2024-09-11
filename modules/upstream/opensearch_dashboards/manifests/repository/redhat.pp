# @summary
#  Install the RedHat yum repository for OpenSearch Dashboards.
#
# @api private
#
class opensearch_dashboards::repository::redhat {
  assert_private()

  $baseurl = $opensearch_dashboards::version =~ Undef ? {
    true  => pick($opensearch_dashboards::repository_location, 'https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/yum'),
    false => pick($opensearch_dashboards::repository_location, "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${opensearch_dashboards::version[0]}.x/yum"),
  }

  yumrepo { 'opensearch-dashboards':
    ensure        => $opensearch_dashboards::repository_ensure,
    baseurl       => $baseurl,
    repo_gpgcheck => '1',
    gpgcheck      => '1',
    gpgkey        => $opensearch_dashboards::repository_gpg_key,
  }
}
