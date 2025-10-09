# @summary
#   Installs OpenSearch Dashboards via archive, package, or repository.
#
# @api private
#
class opensearch_dashboards::install {
  assert_private()

  if $opensearch_dashboards::manage_package {
    if $opensearch_dashboards::package_source == 'archive' {
      contain opensearch_dashboards::install::archive
    } else {
      contain opensearch_dashboards::install::package
    }
  }
}
