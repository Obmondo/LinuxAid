#
# @summary manages the wireguard package
#
# @param manage_package if the package should be managed or not
# @param package_name the name of the package
# @param package_ensure the ensure state of the package
# @param config_directory the path to the wireguard directory
# @param purge_unknown_keys by default Puppet will purge unknown wireguard keys from `$config_directory`
# @param interfaces hash of interfaces to create. Provides hiera integration.
# @param default_allowlist array of allowed IP ranges for interfaces. Can be overwritten for individual interfaces
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class wireguard (
  Boolean $manage_package = true,
  String[1] $package_name = 'wireguard-tools',
  Enum['installed', 'latest', 'absent'] $package_ensure = 'installed',
  Stdlib::Absolutepath $config_directory = '/etc/wireguard',
  Boolean $purge_unknown_keys = true,
  Hash[String[1], Any] $interfaces = {},
  Array[Stdlib::IP::Address] $default_allowlist = ['fe80::/64', 'fd00::/8', '0.0.0.0/0'],
) {
  if $manage_package {
    package { 'wireguard-tools':
      ensure => 'installed',
    }
    Package[$package_name] -> File[$config_directory]
  }
  $_file_ensure = $package_ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }
  if $purge_unknown_keys {
    $options = { recurse => true, purge => true }
  } else {
    $options = undef
  }
  # created by the package, but with different permissions
  file { $config_directory:
    ensure => $_file_ensure,
    owner  => 'root',
    mode   => '0750',
    group  => 'systemd-network',
    *      => $options,
  }

  $interfaces.each |$interfacename, $interfaceattributes| {
    wireguard::interface { $interfacename:
      * => $interfaceattributes,
    }
  }
}
