# @summary
#   Configure OpenSearch Dashboards.
#
# @api private
#
class opensearch_dashboards::config {
  assert_private()

  if $opensearch_dashboards::manage_config {
    $config_directory = $opensearch_dashboards::package_source ? {
      'archive' => "${opensearch_dashboards::package_directory}/config",
      default   => '/etc/opensearch-dashboards',
    }

    file { "${config_directory}/opensearch_dashboards.yml":
      ensure  => file,
      owner   => 'opensearch-dashboards',
      group   => 'opensearch-dashboards',
      mode    => '0640',
      content => $opensearch_dashboards::settings.stdlib::to_yaml,
    }
  }
}
