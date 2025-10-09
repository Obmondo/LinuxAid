# @summary
#   Install OpenSearch Dashboards via tarball.
#
# @api private
#
class opensearch_dashboards::install::archive {
  assert_private()

  if $opensearch_dashboards::version =~ Undef {
    fail("Using 'opensearch_dashboards::package_source: archive' requires to set a version via 'opensearch_dashboards::version: <version>'!")
  }

  $file = "opensearch-dashboards-${opensearch_dashboards::version}-linux-${opensearch_dashboards::package_architecture}.tar.gz"

  user { 'opensearch-dashboards':
    ensure     => $opensearch_dashboards::package_ensure,
    home       => $opensearch_dashboards::package_directory,
    managehome => false,
    system     => true,
    shell      => '/bin/false',
  }

  if $opensearch_dashboards::package_ensure == 'present' {
    file { $opensearch_dashboards::package_directory:
      ensure => 'directory',
      owner  => 'opensearch-dashboards',
      group  => 'opensearch-dashboards',
    }

    file { '/var/lib/opensearch-dashboards':
      ensure => 'directory',
      owner  => 'opensearch-dashboards',
      group  => 'opensearch-dashboards',
    }

    file { '/var/log/opensearch-dashboards':
      ensure => 'directory',
      owner  => 'opensearch-dashboards',
      group  => 'opensearch-dashboards',
    }

    archive { "/tmp/${file}":
      extract         => true,
      extract_path    => $opensearch_dashboards::package_directory,
      extract_command => "tar xf %s --strip-components 1 -C ${opensearch_dashboards::package_directory}",
      user            => 'opensearch-dashboards',
      group           => 'opensearch-dashboards',
      creates         => "${opensearch_dashboards::package_directory}/bin/opensearch-dashboards",
      cleanup         => true,
      source          => "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${opensearch_dashboards::version}/${file}",
    }
  } else {
    file { $opensearch_dashboards::package_directory:
      ensure  => $opensearch_dashboards::package_ensure,
      recurse => true,
      force   => true,
    }

    file { '/var/lib/opensearch-dashboards':
      ensure  => $opensearch_dashboards::package_ensure,
      recurse => true,
      force   => true,
    }

    file { '/var/log/opensearch-dashboards':
      ensure  => $opensearch_dashboards::package_ensure,
      recurse => true,
      force   => true,
    }
  }
}
