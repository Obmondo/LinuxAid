# @summary Manage NGINX package installation on debian based systems
# @api private
class nginx::package::debian {
  $package_name             = $nginx::package_name
  $package_source           = $nginx::package_source
  $package_ensure           = $nginx::package_ensure
  $package_flavor           = $nginx::package_flavor
  $passenger_package_ensure = $nginx::passenger_package_ensure
  $passenger_package_name   = $nginx::passenger_package_name
  $manage_repo              = $nginx::manage_repo
  $release                  = $nginx::repo_release
  $repo_source              = $nginx::repo_source

  $distro = downcase($facts['os']['name'])

  package { 'nginx':
    ensure => $package_ensure,
    name   => $package_name,
  }

  if $manage_repo {
    include 'apt'
    Exec['apt_update'] -> Package['nginx']

    case $package_source {
      'nginx', 'nginx-stable': {
        $stable_repo_source = $repo_source ? {
          undef => "https://nginx.org/packages/${distro}",
          default => $repo_source,
        }
        apt::source { 'nginx':
          location     => $stable_repo_source,
          repos        => 'nginx',
          key          => {
            'name'   => 'nginx.asc',
            'source' => 'https://nginx.org/keys/nginx_signing.key',
          },
          release      => $release,
          architecture => $facts['os']['architecture'],
        }
      }
      'nginx-mainline': {
        $mainline_repo_source = $repo_source ? {
          undef => "https://nginx.org/packages/mainline/${distro}",
          default => $repo_source,
        }
        apt::source { 'nginx':
          location     => $mainline_repo_source,
          repos        => 'nginx',
          key          => {
            'name'   => 'nginx.asc',
            'source' => 'https://nginx.org/keys/nginx_signing.key',
          },
          release      => $release,
          architecture => $facts['os']['architecture'],
        }
      }
      'passenger': {
        $passenger_repo_source = $repo_source ? {
          undef => 'https://oss-binaries.phusionpassenger.com/apt/passenger',
          default => $repo_source,
        }
        apt::source { 'nginx':
          location     => $passenger_repo_source,
          repos        => 'main',
          key          => {
            'name'   => 'phusionpassenger.asc',
            'source' => 'https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt',
          },
          architecture => $facts['os']['architecture'],
        }
        package { $passenger_package_name:
          ensure  => $passenger_package_ensure,
          require => Exec['apt_update'],
        }

        if $package_name != 'nginx-extras' {
          warning('You must set $package_name to "nginx-extras" to enable Passenger')
        }
      }
      default: {
        fail("\$package_source must be 'nginx-stable', 'nginx-mainline' or 'passenger'. It was set to '${package_source}'")
      }
    }
  }
}
