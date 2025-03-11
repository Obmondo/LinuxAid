# Docker role
class role::virtualization::docker (
  Stdlib::Absolutepath                 $docker_lib_dir      = '/var/lib/docker',
  Optional[Eit_types::IPCIDR]          $fixed_cidr          = undef,
  Optional[Eit_types::IPCIDR]          $bip                 = undef,
  Optional[Eit_types::IP]              $default_gateway     = undef,
  Eit_types::SimpleString              $bridge_interface    = 'docker0',
  Hash                                 $instances           = {},
  Eit_types::Docker::ComposeInstances  $compose_instances   = {},
  Boolean                              $manage_compose      = true,
  Hash                                 $networks            = {},
  Optional[Array[Stdlib::IP::Address]] $dns                 = undef,
  Optional[Array[Eit_types::Domain]]   $dns_search          = undef,
  Optional[Array[Eit_types::FQDNPort]] $insecure_registries = undef,
  Array[Eit_types::User]               $users               = [],
  Boolean                              $prune_system        = true,
  Boolean                              $prune_volume        = true,
  Eit_types::Package_Version           $compose_version     = 'present',
  Hash[Eit_types::Domain, Hash]        $registry            = {},
  Boolean                              $upstream_repo       = true,
  String                               $cadvisor_image      = 'gcr.io/cadvisor/cadvisor:v0.39.0',
) inherits ::role::virtualization {

  $_allow_docker = lookup('common::network::firewall::allow_docker', Boolean, undef, false)

  confine(!$_allow_docker, 'This role needs the setting `common::network::firewall::allow_docker` to be enabled!')

  confine($manage_compose, !$compose_instances, 'A compose instance must be present if managing compose')
  confine($bip, $bridge_interface,
          '`$bip` and `$bridge_interface` cannot be set simultaneously')

  contain profile::virtualization::docker

}
