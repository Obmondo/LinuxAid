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
#   Accepts a string or SemVer object.  
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
#     version => '1.4.4',  
#   }  
#  
# @example Disable client management  
#   class { 'rustdesk::client':  
#     enable => false,  
#   }  
#  
class rustdesk::client (
  Boolean                    $enable             = $rustdesk::client_enable,
  Variant[String[1], SemVer] $version            = $rustdesk::client_version,
  Array[String]              $extra_dependencies = $rustdesk::client_extra_dependencies,
) {
  $_version = SemVer($version)
  $_arch = pick($facts['os']['architecture'], 'x86_64')
  $_client_arch = $_arch ? {
    /(amd64|x86_64)/ => 'x86_64',
    /(arm64|aarch64)/ => 'aarch64',
    default          => fail("Unsupported architecture for RustDesk client: ${_arch}"),
  }

  # Fixed common dependencies
  $common_deps = lookup('rustdesk::client_dependencies')

  # Merge common + OS-specific dependencies
  $dependencies = concat($common_deps, $extra_dependencies)

  $package_name  = "rustdesk-${_version}-${_client_arch}.deb"
  $package_url   = "https://github.com/rustdesk/rustdesk/releases/download/${_version}/${package_name}"
  $download_path = "/tmp/${package_name}"

  $_package_ensure = $enable ? {
    true    => "${_version}",
    default => 'absent',
  }

  # Ensure dependencies are installed first
  package { $dependencies:
    ensure => stdlib::ensure($enable, 'package'),
  }

  archive { $download_path:
    ensure  => stdlib::ensure($enable),
    source  => $package_url,
    creates => $download_path,
  }

  package { 'rustdesk':
    ensure  => $_package_ensure,
    source  => $download_path,
    require => Archive[$download_path],
    notify  => Service['rustdesk'],
  }

  service { 'rustdesk':
    ensure  => stdlib::ensure($enable, 'service'),
    enable  => $enable,
    require => Package['rustdesk'],
  }
}
