# @summary
#   Install OpenSearch Dashboards via deb/rpm package.
#
# @api private
#
class opensearch_dashboards::install::package {
  assert_private()

  if $opensearch_dashboards::package_source == 'download' {
    if $opensearch_dashboards::version =~ Undef {
      fail("Using 'opensearch_dashboards::package_source: download' requires to set a version via 'opensearch_dashboards::version: <version>'!")
    }

    $ensure   = $opensearch_dashboards::package_ensure
    $provider = $opensearch_dashboards::package_provider
    $file     = $opensearch_dashboards::package_provider ? {
      'dpkg' => "opensearch-dashboards-${opensearch_dashboards::version}-linux-${opensearch_dashboards::package_architecture}.deb",
      'rpm'  => "opensearch-dashboards-${opensearch_dashboards::version}-linux-${opensearch_dashboards::package_architecture}.rpm",
    }
    $source   = "/tmp/${file}"

    archive { $source:
      provider => 'wget',
      extract  => false,
      cleanup  => true,
      source   => "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${opensearch_dashboards::version}/${file}",
    }

    Archive[$source] -> Package['opensearch-dashboards']
  } else {
    $ensure   = pick($opensearch_dashboards::version, $opensearch_dashboards::package_ensure)
    $provider = undef
    $source   = undef

    if $opensearch_dashboards::manage_repository {
      contain opensearch_dashboards::repository
    }

    if $opensearch_dashboards::version !~ Undef and $opensearch_dashboards::pin_package {
      case $facts['os']['family'] {
        'Debian': {
          include apt

          apt::pin { 'opensearch-dashboards':
            version  => $opensearch_dashboards::version,
            packages => 'opensearch-dashboards',
            priority => $opensearch_dashboards::apt_pin_priority,
          }
        }
        'RedHat': {
          include yum

          yum::versionlock { 'opensearch-dashboards':
            version => $opensearch_dashboards::version,
          }
        }
        default: {
          fail('Package pinning is not available for your OS!')
        }
      }
    }
  }

  package { 'opensearch-dashboards':
    ensure   => $ensure,
    provider => $provider,
    source   => $source,
  }
}
