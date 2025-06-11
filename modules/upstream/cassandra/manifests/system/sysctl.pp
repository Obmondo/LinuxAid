# Set Sysctl (kernel runtime parameters) as suggested in
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html
#
# If any of the values is set into the target file, the sysctl command will
# be called with the provided file name as an argument.
#
# @example Basic requirement
#   require cassandra::system::sysctl
#
# @param sysctl_args [string] Passed to the `sysctl` command
# @param sysctl_file [string] Path to the file to insert the settings into.
# @param net_core_optmem_max [integer] The value to set for
#   net.core.optmem_max
# @param net_core_rmem_default [integer] The value to set for
#   net.core.rmem_default.
# @param net_core_rmem_max [integer] The value to set for net_core_rmem_max.
# @param net_core_wmem_default [integer] The value to set for
#   net.core.wmem_default.
# @param net_core_wmem_max [integer] The value to set for net.core.wmem_max.
# @param net_ipv4_tcp_rmem [string] The value to set for net.ipv4.tcp_rmem.
# @param net_ipv4_tcp_wmem [string] The value to set for net.ipv4.tcp_wmem.
# @param vm_max_map_count [integer] The value to set for vm.max_map_count.
# @see cassandra::params
class cassandra::system::sysctl (
  $sysctl_args           = '-p',
  $sysctl_file           = $cassandra::params::sysctl_file,
  $net_core_optmem_max   = 40960,
  $net_core_rmem_default = 16777216,
  $net_core_rmem_max     = 16777216,
  $net_core_wmem_default = 16777216,
  $net_core_wmem_max     = 16777216,
  $net_ipv4_tcp_rmem     = $cassandra::params::net_ipv4_tcp_rmem,
  $net_ipv4_tcp_wmem     = $cassandra::params::net_ipv4_tcp_wmem,
  $vm_max_map_count      = 1048575,
) inherits cassandra::params {
  ini_setting { "net.core.rmem_max = ${net_core_rmem_max}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.core.rmem_max',
    value   => $net_core_rmem_max,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.core.wmem_max = ${net_core_wmem_max}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.core.wmem_max',
    value   => $net_core_wmem_max,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.core.rmem_default = ${net_core_rmem_default}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.core.rmem_default',
    value   => $net_core_rmem_default,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.core.wmem_default = ${net_core_wmem_default}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.core.wmem_default',
    value   => $net_core_wmem_default,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.core.optmem_max = ${net_core_optmem_max}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.core.optmem_max',
    value   => $net_core_optmem_max,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.ipv4.tcp_rmem = ${net_ipv4_tcp_rmem}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.ipv4.tcp_rmem',
    value   => $net_ipv4_tcp_rmem,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "net.ipv4.tcp_wmem = ${net_ipv4_tcp_wmem}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'net.ipv4.tcp_wmem',
    value   => $net_ipv4_tcp_wmem,
    notify  => Exec['Apply sysctl changes'],
  }

  ini_setting { "vm.max_map_count = ${vm_max_map_count}":
    ensure  => present,
    path    => $sysctl_file,
    section => '',
    setting => 'vm.max_map_count',
    value   => $vm_max_map_count,
    notify  => Exec['Apply sysctl changes'],
  }

  exec { 'Apply sysctl changes':
    command     => "/sbin/sysctl ${sysctl_args} ${sysctl_file}",
    refreshonly => true,
  }
}
