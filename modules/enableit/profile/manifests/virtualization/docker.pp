# Docker profile
class profile::virtualization::docker (
  Stdlib::Absolutepath                 $docker_lib_dir      = $role::virtualization::docker::docker_lib_dir,
  Boolean                              $manage_compose      = $role::virtualization::docker::manage_compose,
  Hash                                 $instances           = $role::virtualization::docker::instances,
  Eit_types::Docker::ComposeInstances  $compose_instances   = $role::virtualization::docker::compose_instances,
  Hash                                 $networks            = $role::virtualization::docker::networks,
  Optional[Array[Stdlib::IP::Address]] $dns                 = $role::virtualization::docker::dns,
  Optional[Array[Eit_types::Domain]]   $dns_search          = $role::virtualization::docker::dns_search,
  Optional[Array[Eit_types::FQDNPort]] $insecure_registries = $role::virtualization::docker::insecure_registries,
  Array[Eit_types::User]               $users               = $role::virtualization::docker::users,
  Optional[Eit_types::IPCIDR]          $fixed_cidr          = $role::virtualization::docker::fixed_cidr,
  Optional[Eit_types::IPCIDR]          $bip                 = $role::virtualization::docker::bip,
  Optional[Eit_types::IP]              $default_gateway     = $role::virtualization::docker::default_gateway,
  Eit_types::SimpleString              $bridge_interface    = $role::virtualization::docker::bridge_interface,
  Boolean                              $prune_system        = $role::virtualization::docker::prune_system,
  Boolean                              $prune_volume        = $role::virtualization::docker::prune_volume,
  Hash[Eit_types::Domain, Hash]        $registry            = $role::virtualization::docker::registry,
) {

  $__cadvisor_listen_port = 63392

  $dns_resolver = lookup('common::system::dns::resolver')
  $dns_listen_on = lookup('common::system::dns::listen_address')

  confine ($dns, $dns_resolver != 'dnsmasq', 'docker dns can only work with dnsmasq or you remove the dns to work with systems default')

# Disabling the confine for server dkcphaf01 check ticket #11959. Will enable it once the issue is solved.
  if  $dns == ['192.168.0.1'] {
    confine ($dns, $dns_listen_on != $dns, "docker dns IP given seems to be wrong, since no DNS server is listening on the given IP ${dns}")
  }

  class { 'profile::virtualization::docker::cadvisor':
    listen_port => $__cadvisor_listen_port,
  }

  if $facts['init_system'] == 'systemd' {
    class { 'common::monitor::exporter::cadvisor':
      listen_port => $__cadvisor_listen_port,
    }
  }

  # all the resources Docker containers depend on
  $_docker_resources = [
    File['/etc/docker/daemon.json'],
  ]

  Service {
    subscribe => $_docker_resources,
  }

  file { '/etc/docker':
    ensure => 'directory'
  }

  file { '/etc/docker/daemon.json':
    ensure  => 'present',
    content => to_json_pretty(
      [
        {
          'default-address-pools' => [
            {
              'base' => '192.168.0.0/16',
              'size' => 24,
            },
          ],
        },
        if $dns {
          {
            'dns' => $dns,
          }
        },
        if $dns_search {
          {
            'dns-search' => $dns_search,
          }
        },
        if $insecure_registries {
          {
            'insecure-registries' => $insecure_registries,
          }
        }
      ].merge_hashes),
    before  => Class['docker'],
    require => File['/etc/docker'],
  }

  class { '::docker':
    ensure                      => 'present',
    ip_forward                  => true,
    iptables                    => true,
    ip_masq                     => true,
    log_driver                  => 'local',
    selinux_enabled             => $facts.dig('selinux'),
    use_upstream_package_source => true,
    service_state               => 'running',
    service_enable              => true,
    manage_service              => true,
    root_dir                    => $docker_lib_dir,
    docker_users                => $users,
    log_opt                     => [ 'max-size=10m', 'max-file=3' ]
    # bridge                      => $bridge_interface,
    # fixed_cidr                  => $fixed_cidr,
    # bip                         => $bip,
    # default_gateway             => $default_gateway,
    # dns                         => $dns,
  }

  $registry.each |$k, $s| {
    docker::registry { $k :
      *    => $s,
      noop => false,
    }
  }

  $instances.each |$instance_name, $instance| {
    if $facts.dig('selinux') {
      $instance['ports'].each |$_docker_port| {
        $_port_details = docker_port_details($_docker_port)

        $_name = [
          'allow-http-docker',
          $instance_name,
          $_port_details['src_port'],
          $_port_details['protocol'],
        ].delete_undef_values.join('-')

        selinux::port { $_name:
          seltype  => 'http_port_t',
          protocol => pick($_port_details['protocol'], 'tcp'),
          port     => $_port_details['src_port'],
        }
      }
    }

    $_requires = $instance.dig('net').then |$_net| {
      if $_net != 'bridge' {
        [Docker_network[$_net]]
      }
    }.lest || { [] }

    docker::run { $instance_name:
      *         => $instance,
      require   => [Class['docker']] + $_requires,
      subscribe => $_docker_resources,
    }
  }

  if $manage_compose {
    include docker::compose
  }

  file { '/opt/obmondo/docker-compose':
    ensure => ensure_dir($manage_compose),
  }

  $compose_instances.each |$key, $value| {
    $_docker_compose = eit_files::to_file($value['compose_files'])
    $_docker_compose_base = "/opt/obmondo/docker-compose/${key}"
    $_docker_compose_base_file = "${_docker_compose_base}/docker-compose.yml"

    # Create dir for all files related to compose stack
    file { $_docker_compose_base:
      ensure  => 'directory',
      recurse => true,
      source  => $_docker_compose['resource']['source'],
    }

    if $value['envs'] {
      file { "${_docker_compose_base}/.env":
        ensure  => present,
        content => anything_to_ini($value['envs'])
      }
    }

    # NOTE don't remove compose files, docker_compose needs it to stop the
    # compose stack
    docker_compose { $key:
      ensure        => pick($value['ensure'], 'present'),
      compose_files => [$_docker_compose_base_file],
      require       => File[$_docker_compose_base],
      subscribe     => $_docker_resources,
    }

    if $value.dig('refresh_on_change') {
      exec { "docker-compose refresh ${key}":
        command     => "docker-compose -f ${_docker_compose_base_file} up -d",
        refreshonly => true,
        path        => [
          '/bin',
          '/usr/bin',
          '/usr/sbin',
          '/usr/local/bin',
        ],
        subscribe   => [
          File[$_docker_compose_base],
        ] + $_docker_resources,
      }
    }
  }

  $networks.each |$network_name, $network| {
    docker_network { $network_name:
      *         => $network,
      subscribe => $_docker_resources,
    }
  }

  profile::cron::job { 'regularly prune docker system':
    enable  => $prune_system,
    command => 'chronic docker system prune --all --force --filter until=$(( 30 * 24 ))h',
    user    => 'root',
    hour    => 2,
    minute  => 5,
    require => Class['docker'],
  }

  firewall_multi { '110 allow docker dns':
    ensure  => present,
    iniface => 'docker0',
    dport   => 53,
    proto   => [
      'tcp',
      'udp',
    ],
    jump    => 'accept',
  }
}
