# @summary Manages the RustDesk server installation and configuration  
#  
# This class handles the installation and management of the RustDesk remote desktop server.  
# It controls whether the server is enabled, which version to install, and manages  
# any required dependencies.  
#  
# @param enable  
#   Whether to enable and manage the RustDesk server.  
#   When set to false, the server will not be installed or managed.  
#  
# @param version  
#   The version of RustDesk server to install.  
#   Must be a valid version string conforming to SemVer.  
#
# @param extra_dependencies  
#   Array of OS specific package names that are required dependencies for the RustDesk server.  
#   These packages will be installed before the RustDesk server.  
#  
# @example Basic usage with defaults  
#   include rustdesk::server  
#  
# @example Install specific version  
#   class { 'rustdesk::server':  
#     version => '1.7.1',  
#   }  
#  
# @example Disable server management  
#   class { 'rustdesk::server':  
#     enable => false,  
#   }  
#  
class rustdesk::server (
  Boolean            $enable             = $rustdesk::server_enable,
  SemVer             $version            = $rustdesk::server_version,
  Array[String]      $extra_dependencies = $rustdesk::server_extra_dependencies,
) {
  # Fixed common dependencies
  $common_deps = lookup('rustdesk::server_dependencies')

  # Merge common + OS-specific dependencies
  $dependencies = concat($common_deps, $extra_dependencies)

  # Ensure dependencies are installed first
  package { $dependencies:
    ensure => stdlib::ensure($enable, 'package'),
  }

  $servers = lookup('rustdesk::server::package_names')

  $servers.each | $server_type, $package_name | {
    $package_url="https://github.com/rustdesk/rustdesk-server-pro/releases/download/${version}/${package_name}_${version}_amd64.deb"
    $download_path = "/tmp/${package_name}_${version}_amd64.deb"

    archive { $download_path :
      ensure => stdlib::ensure($enable),
      source => $package_url,
    }

    package { $package_name:
      ensure  => stdlib::ensure($enable, 'package'),
      source  => $download_path,
      require => Archive[$download_path],
    }

    service { regsubst($package_name, '-server', '', 'G'):
      ensure  => stdlib::ensure($enable, 'service'),
      enable  => $enable,
      require => Package[$package_name],
    }
  }
}
