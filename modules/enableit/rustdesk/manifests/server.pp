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
    ensure => installed,
  }

  ['relay', 'signal'].each |$server| {
    $_server_type = lookup("rustdesk::server::${server}::package_name")
    $_package_url="https://github.com/rustdesk/rustdesk-server-pro/releases/download/${version}/${_server_type}_${version}_amd64.deb"

    archive { $server :
      ensure => $enable,
      source => $_package_url,
    }

    package { $_server_type:
      ensure   => installed,
      provider => 'dpkg',
      source   => "/tmp/${server}",
      require  => Archive[$server],
    }

    service { $_server_type:
      ensure  => $enable,
      enable  => $enable,
      require => Package[$server],
    }
  }
}
