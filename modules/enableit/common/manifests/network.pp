# Network config
class common::network (
  Enum[
    'systemd-networkd',
    'network',
    'networking'
  ]             $service_name,
  Boolean       $manage              = false,
  Boolean       $purge               = true,
  Boolean       $restart_on_change   = true,
  String        $ipaddress_package   = undef,
  String        $ipaddress_provider  = undef,
  Hash[Pattern[/^[:a-z0-9]+$/],Struct[{
    family    => Optional[Enum['inet']],
    ipaddress => Optional[Stdlib::IP::Address],
    netmask   => Optional[Stdlib::IP::Address],
    method    => Optional[Enum['static', 'dhcp']],
    onboot    => Optional[Boolean],
    gateway   => Optional[Stdlib::IP::Address], # only when its systemd-networkd
  }]]           $interfaces          = {},
  Hash          $bonded_interfaces   = {},
  Hash[Pattern[/^[a-z0-9]+$/],Struct[{
    gateway => Stdlib::IP::Address,
    network => Pattern[/^[a-z0-9]+$/],
    netmask => Stdlib::IP::Address,
    interface  => Pattern[/^[a-z0-9]+$/],
  }]]           $routes              = {},
  Array[String] $__required_packages = [],
) inherits ::common {
  $_uses_dhcp = $interfaces.map |$_, $_interface_options| { $_interface_options.dig('method') }.grep('dhcp').size >= 1

  $_uses_gateway = $interfaces.map |$_, $_interface_options| { $_interface_options.dig('gateway').empty }[0]

  confine($manage,
          $interfaces.size > 1 or $bonded_interfaces.size > 1,
          $routes.size < 1 or $routes.dig('default') == undef,
          !$_uses_dhcp,
          $service_name != 'systemd-networkd',
          'when managing network interfaces a default route (a route named "default") must be given in `$routes` unless DHCP is used')

  confine($manage,
          !$_uses_dhcp,
          $routes.dig('default') =~ Undef,
          $service_name != 'systemd-networkd',
          'a default route needs to be configured')

  confine($manage,
          !$_uses_dhcp,
          $_uses_gateway,
          $service_name == 'systemd-networkd',
          'gateway needs to be configured')

  confine($manage,
          !$_uses_dhcp,
          $routes.dig('default', 'network') != 'default',
          $service_name != 'systemd-networkd',
          'the default route should be have parameter `network` set to "default"')

  if $manage {
    # NOTE: We don't use network manager at any place.
    service { [
      'NetworkManager',
      'NetworkManager-wait-online',
    ]:
      ensure => 'stopped',
      enable => false,
      before => Service[$service_name],
    }

    case $service_name {
      'systemd-networkd': {
        include ::profile::system::systemd

        # Bonded not supported
        $interfaces.each |$_name, $_config| {
          if type($_config['ipaddress']) =~ Type[Stdlib::IP::Address::V4::CIDR] or $_uses_dhcp {
            $_is_dhcp = $_uses_dhcp.to_yesno
            systemd::network { "10-${_name}.network":
              # systemd-resolved is required if DNS entries are specified in .network files.
              content => "
[Match]
Name=${_name}

[Network]
DHCP=${_is_dhcp}
Address=${_config['ipaddress']}

[Route]
Gateway=${_config['gateway']}
"
            }
          } else {
            fail("Given ipaddress ${_config['ipaddress']} is not correct and is not supported by systemd-networkd")
          }
        }
      }

      # TODO: Add support for interface file.
      default: {
        class { '::network':
          ipaddress          => $ipaddress_package,
          ipaddress_provider => $ipaddress_provider,
        }

        package::install($__required_packages, {
          before => Network_config['lo'],
        })

        $_network_notify = if $restart_on_change {
          Service['network']
        }

        if $facts['init_system'] == 'systemd' {
          systemd::unit_file { [
            'systemd-networkd.service',
            'systemd-networkd.socket',
            'systemd-networkd-wait-online.service',
          ]:
            ensure => 'present',
            enable => 'mask',
            active => false,
            before => Service['network'],
          }
        }

        service { 'network':
          ensure     => 'running',
          enable     => true,
          name       => $service_name,
          hasrestart => true,
        }

        if $purge and $::facts.dig('os', 'family') == 'RedHat' {
          tidy { '/etc/sysconfig/network-scripts':
            age     => '0',
            recurse => 1,
            matches => [
              'ifcfg-*',
              'route-*',
            ],
          }
        }

        $_lo_method = $facts.dig('os', 'family') ? {
          'Debian' => 'loopback',
          'RedHat' => 'static',
        }

        network_config { 'lo':
          ensure => 'present',
          family => 'inet',
          method => $_lo_method,
          onboot => true,
        }

        # To avoid purging the ifcfg file
        if $facts.dig('os', 'family') == 'RedHat' {
          file { '/etc/sysconfig/network-scripts/ifcfg-lo':
            ensure => 'file',
          }
        }

        $interfaces.each |$_name, $_config| {
          if !$_config['family'] or !$_config['method'] or !$_config['onboot'] {
            fail('required params are missing')
          }

          network_config { $_name:
            ensure    => 'present',
            family    => $_config['inet'],
            ipaddress => $_config['ipaddress'],
            netmask   => $_config['netmask'],
            method    => $_config['method'],
            onboot    => $_config['onboot'],
            notify    => $_network_notify,
          }

          # To avoid purging the ifcfg file
          if $facts.dig('os', 'family') == 'RedHat' {
            file { "/etc/sysconfig/network-scripts/ifcfg-${_name}":
              ensure => 'file',
            }
          }
        }

        $bonded_interfaces.each |$_name, $_config| {
          $_merged_config = $_config + {
            # make sure we have 'yes'/'no' instead of booleans
            'slave_options' => $_config.dig('slave_options').lest || { {} }.reduce({}) |$acc, $kv| {
              [$k, $v] = $kv
              $acc + {
                $k => $v ? {
                  Boolean => to_yesno($v),
                  default => $v,
                }
              }
            }
          }

          network::bond { $_name:
            *      => $_merged_config,
            notify => $_network_notify,
          }

          if $facts.dig('os', 'family') == 'RedHat' {
            $_ifcfg_slave_files = $_merged_config['slaves'].map |$_slave| {
              "/etc/sysconfig/network-scripts/ifcfg-${_slave}"
            }

            $_ifcfg_files = [
              "/etc/sysconfig/network-scripts/ifcfg-${_name}",
              $_ifcfg_slave_files,
            ].flatten

            # To avoid purging the bonding interface file
            file { $_ifcfg_files :
              ensure => 'file',
            }
          }
        }

        $routes.each |$_name, $_config| {
          network_route { $_name:
            ensure => 'present',
            *      => $_config,
            notify => $_network_notify,
          }

          # To avoid purging the route file
          if $facts.dig('os', 'family') == 'RedHat' {
            file { '/etc/sysconfig/network':
              ensure  => 'file',
              content => "GATEWAY=${_config['gateway']}\n",
            }

            file { "/etc/sysconfig/network-scripts/route-${_config['interface']}":
              ensure => 'file',
            }
          }
        }
      }
    }
  }

  if lookup('common::network::firewall::enable', Boolean, undef, false) {
    'common::network::firewall'.contain
  }

  unless lookup('common::network::stunnel', Hash, undef, {}).empty {
    'common::network::stunnel'.contain
  }

  if lookup('common::network::vrrp::enable', Boolean, undef, false) {
    'common::network::vrrp'.contain
  }

  if lookup('common::network::wireguard::enable', Boolean, undef, false) {
    'common::network::wireguard'.contain
  }

  if lookup('common::network::netbird::enable', Boolean, undef, false) {
    'common::network::netbird'.contain
  }

  if lookup('common::network::tcpshaker::enable', Boolean, undef, false) {
    'common::network::tcpshaker'.contain
  }
}
