# @summary
#   Handle OpenSearch Dashboards repository.
#
# @api private
#
class opensearch_dashboards::repository {
  assert_private()

  case $facts['os']['family'] {
    'RedHat': {
      contain opensearch_dashboards::repository::redhat
    }
    'Debian': {
      contain opensearch_dashboards::repository::debian
    }
    default: {
      fail("Your OS ${facts['os']['family']} (${facts['os']['name']}) is not supported to use a repository for installing opensearch dashboards!")
    }
  }
}
