# @summary Manages the RustDesk client installation and configuration  
#  
# This class handles the installation and management of the RustDesk remote desktop client.  
# It controls whether the client is enabled, which version to install, and manages  
# any required dependencies.  
#  
# @param enable  
#   Whether to enable and manage the RustDesk client.  
#   When set to false, the client will not be installed or managed.  
#  
# @param version  
#   The version of RustDesk client to install.  
#   Must be a valid version string conforming to SemVer.  
#  
# @param extra_dependencies  
#   Array of OS specific package names that are required dependencies for the RustDesk client.  
#   These packages will be installed before the RustDesk client.  
#  
# @example Basic usage with defaults  
#   include rustdesk::client  
#  
# @example Install specific version  
#   class { 'rustdesk::client':  
#     version => '1.4.3',  
#   }  
#  
# @example Disable client management  
#   class { 'rustdesk::client':  
#     enable => false,  
#   }  
#  
class rustdesk::client (
  Boolean            $enable             = $rustdesk::client_enable,
  SemVer             $version            = $rustdesk::client_version,
  Array[String]      $extra_dependencies = $rustdesk::client_extra_dependencies,
) {
  # Fixed common dependencies
  $common_deps = lookup('rustdesk::client_dependencies')

  # Merge common + OS-specific dependencies
  $dependencies = concat($common_deps, $extra_dependencies)

  $package_url   = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.deb"
  $package_name  = "rustdesk-${version}-x86_64.deb"
  $download_path = "/tmp/${package_name}"

  # Ensure dependencies are installed first
  package { $dependencies:
    ensure => installed,
  }

  archive { $download_path:
    ensure => ensure_present($enable),
    source => $package_url,
  }

  package { 'rustdesk':
    ensure   => installed,
    provider => 'dpkg',
    source   => $download_path,
    require  => Archive[$download_path],
  }

  service { 'rustdesk.service':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['rustdesk'],
  }
}
