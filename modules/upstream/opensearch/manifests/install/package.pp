# @summary
#   Install opensearch via deb/rpm package.
#
# @api private
#
class opensearch::install::package {
  assert_private()

  if $opensearch::package_source == 'download' {
    if $opensearch::version =~ Undef {
      fail("Using 'opensearch::package_source: download' requires to set a version via 'opensearch::version: <version>'!")
    }

    $ensure   = $opensearch::package_ensure
    $provider = $opensearch::package_provider
    $file     = $opensearch::package_provider ? {
      'dpkg' => "opensearch-${opensearch::version}-linux-${opensearch::package_architecture}.deb",
      'rpm'  => "opensearch-${opensearch::version}-linux-${opensearch::package_architecture}.rpm",
    }
    $source   = "/tmp/${file}"

    archive { $source:
      provider => 'wget',
      extract  => false,
      cleanup  => true,
      source   => "https://artifacts.opensearch.org/releases/bundle/opensearch/${opensearch::version}/${file}",
    }

    Archive[$source] -> Package['opensearch']
  } else {
    $ensure   = pick($opensearch::version, $opensearch::package_ensure)
    $provider = undef
    $source   = undef

    if $opensearch::manage_repository {
      contain opensearch::repository
    }

    if $opensearch::version !~ Undef and $opensearch::pin_package {
      case $facts['os']['family'] {
        'Debian': {
          include apt

          apt::pin { 'opensearch':
            version  => $opensearch::version,
            packages => 'opensearch',
            priority => $opensearch::apt_pin_priority,
          }
        }
        'RedHat': {
          include yum

          yum::versionlock { 'opensearch':
            version => $opensearch::version,
          }
        }
        default: {
          fail('Package pinning is not available for your OS!')
        }
      }
    }
  }

  package { 'opensearch':
    ensure   => $ensure,
    provider => $provider,
    source   => $source,
  }
}
