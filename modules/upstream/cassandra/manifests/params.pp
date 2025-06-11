# This class is meant to be called from the locp-cassandra module.
# It sets variables according to platform.
class cassandra::params {
  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['release']['major'] {
        '12.04': {
          $net_ipv4_tcp_rmem = '4096 87380 16777216'
          $net_ipv4_tcp_wmem = '4096 65536 16777216'
          $java_package = 'openjdk-7-jre-headless'
        }
        '18.04': {
          $net_ipv4_tcp_rmem = '4096 87380 16777216'
          $net_ipv4_tcp_wmem = '4096 65536 16777216'
          $java_package = 'openjdk-8-jre-headless'
        }
        # non-Ubuntu Debian is just... Debian
        default: {
          $net_ipv4_tcp_rmem = '4096, 87380, 16777216'
          $net_ipv4_tcp_wmem = '4096, 65536, 16777216'
          $java_package = 'openjdk-7-jre-headless'
        }
      }

      $cassandra_pkg = 'cassandra'
      $config_path = '/etc/cassandra'
      $jna_package_name = 'libjna-java'
      $optutils_package_name = 'cassandra-tools'
      $sysctl_file = '/etc/sysctl.d/10-cassandra.conf'
      $systemctl = '/bin/systemctl'
      $use_scl = false
      $scl_name = 'nodefault'
    }
    'RedHat': {
      case $facts['os']['release']['major'] {
        '6': {
          $net_ipv4_tcp_rmem = '4096 87380 16777216'
          $net_ipv4_tcp_wmem = '4096 65536 16777216'
          $sysctl_file = '/etc/sysctl.conf'
        }
        '7': {
          $net_ipv4_tcp_rmem = '4096, 87380, 16777216'
          $net_ipv4_tcp_wmem = '4096, 65536, 16777216'
          $sysctl_file = '/etc/sysctl.d/10-cassandra.conf'
        }
        default: {}
      }

      $cassandra_pkg = 'cassandra22'
      $config_path = '/etc/cassandra/default.conf'
      $java_package = 'java-1.8.0-openjdk-headless'
      $jna_package_name = 'jna'
      $optutils_package_name = 'cassandra22-tools'
      $systemctl = '/usr/bin/systemctl'
      $use_scl = false
      $scl_name = 'nodefault'
    }
    default: {
      $config_path_parents = []
    }
  }
}
