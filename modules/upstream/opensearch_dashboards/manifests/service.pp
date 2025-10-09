# @summary
#   Handle OpenSearch Dashboards service.
#
# @api private
#
class opensearch_dashboards::service {
  assert_private()

  if $opensearch_dashboards::manage_service {
    if $opensearch_dashboards::package_source == 'archive' {
      systemd::unit_file { 'opensearch-dashboards.service':
        ensure  => 'present',
        content => epp('opensearch_dashboards/opensearch-dashboards.service.epp'),
        notify  => Service['opensearch-dashboards'],
      }
    }

    service { 'opensearch-dashboards':
      ensure => $opensearch_dashboards::service_ensure,
      enable => $opensearch_dashboards::service_enable,
    }
  }
}
