# @summary Main class for managing RustDesk client and server components  
#  
# This is the primary entry point for the RustDesk module. It provides high-level  
# control over whether the RustDesk client and/or server components should be managed,  
# and which versions to install.  
#  
# @param client_enable  
#   Whether to enable and manage the RustDesk client component.  
#   When set to true, the rustdesk::client class will be included and managed.  
#  
# @param client_version  
#   The version of RustDesk client to install.  
#   Accepts a string or SemVer object.  
#  
# @param client_extra_dependencies  
#   Array of OS specific package names that are required dependencies for the RustDesk client.  
#   These packages will be installed before the RustDesk client.  
#
# @param server_enable  
#   Whether to enable and manage the RustDesk server component.  
#   When set to true, the rustdesk::server class will be included and managed.  
#  
# @param server_version  
#   The version of RustDesk server to install.  
#   Accepts a string or SemVer object.  
#  
# @param server_extra_dependencies  
#   Array of OS specific package names that are required dependencies for the RustDesk server.  
#   These packages will be installed before the RustDesk server.  
#
# @example Enable only the client with specific version  
#   class { 'rustdesk':  
#     client_enable  => true,  
#     client_version => '1.4.4',  
#     server_enable  => false,  
#   }  
#  
# @example Enable both client and server with different versions  
#   class { 'rustdesk':  
#     client_enable  => true,  
#     client_version => '1.4.4',  
#     server_enable  => true,  
#     server_version => '1.7.2',  
#   }  
#  
# @example Basic usage with defaults  
#   include rustdesk  
#
class rustdesk (
  Boolean                    $client_enable,
  Variant[String[1], SemVer] $client_version,
  Array[String]              $client_extra_dependencies,

  Boolean                    $server_enable,
  Variant[String[1], SemVer] $server_version,
  Array[String]              $server_extra_dependencies,
) {
  $_osname = $facts['os']['name']
  if $_osname != 'Ubuntu' {
    fail("The OS you running (${_osname}) isn't supported to setup RustDesk")
  }

  [
    rustdesk::client,
    rustdesk::server,
  ].include
}
