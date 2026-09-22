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
#   Accepts a string or SemVer object.  
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
#     version => '1.7.2',  
#   }  
#  
# @example Disable server management  
#   class { 'rustdesk::server':  
#     enable => false,  
#   }  
#  
class rustdesk::server (
  Boolean                    $enable             = $rustdesk::server_enable,
  Variant[String[1], SemVer] $version            = $rustdesk::server_version,
  Array[String]              $extra_dependencies = $rustdesk::server_extra_dependencies,
) {
  $_version = SemVer($version)
  $_arch = pick($facts['os']['architecture'], 'x86_64')
  $_server_arch = $_arch ? {
    /(amd64|x86_64)/ => 'amd64',
    /(arm64|aarch64)/ => 'arm64',
    default          => fail("Unsupported architecture for RustDesk server: ${_arch}"),
  }

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
    $package_url="https://github.com/rustdesk/rustdesk-server-pro/releases/download/${_version}/${package_name}_${_version}_${_server_arch}.deb"
    $download_path = "/tmp/${package_name}_${_version}_${_server_arch}.deb"

    archive { $download_path :
      ensure  => stdlib::ensure($enable),
      source  => $package_url,
      creates => $download_path,
    }

    package { $package_name:
      ensure  => stdlib::ensure($enable, $_version),
      source  => $download_path,
      require => Archive[$download_path],
      notify  => Service[regsubst($package_name, '-server', '', 'G')],
    }

    service { regsubst($package_name, '-server', '', 'G'):
      ensure  => stdlib::ensure($enable, 'service'),
      enable  => $enable,
      require => Package[$package_name],
    }
  }
}
