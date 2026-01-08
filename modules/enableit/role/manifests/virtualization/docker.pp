# @summary Docker role class
#
# @param docker_lib_dir The directory for Docker library files. Defaults to '/var/lib/docker'.
#
# @param fixed_cidr The fixed CIDR for the Docker network. Defaults to undef.
#
# @param bip The bridge IP address. Defaults to undef.
#
# @param default_gateway The default gateway for Docker networks. Defaults to undef.
#
# @param bridge_interface The Docker bridge interface. Defaults to 'docker0'.
#
# @param instances The Docker instances configuration. Defaults to an empty hash.
#
# @param compose_instances The Docker Compose instances configuration. Defaults to an empty hash.
#
# @param manage_compose Whether to manage Docker Compose. Defaults to true.
#
# @param networks The networks configuration for Docker. Defaults to an empty hash.
#
# @param dns The DNS configuration for Docker. Defaults to undef.
#
# @param dns_search The DNS search domains for Docker. Defaults to undef.
#
# @param insecure_registries The list of insecure registries. Defaults to undef.
#
# @param users The list of users to be added to Docker. Defaults to an empty array.
#
# @param prune_system Whether to prune unused images and containers. Defaults to true.
#
# @param prune_volume Whether to prune unused volumes. Defaults to true.
#
# @param compose_version The version of Docker Compose to install. Defaults to 'present'.
#
# @param registry The registry configuration for Docker. Defaults to an empty hash.
#
# @param upstream_repo Whether to use the upstream repository. Defaults to true.
#
# @param cadvisor_image The cAdvisor image to use. Defaults to 'gcr.io/cadvisor/cadvisor:v0.39.0'.
#
# @param prune_duration The parameter prune_duration specifies the duration in days for which unused Docker resources will be retained before being pruned. Defaults to '30'.
#
# @groups network fixed_cidr, bip, default_gateway, bridge_interface, dns, dns_search, networks
#
# @groups compose manage_compose, compose_instances, compose_version
#
# @groups storage docker_lib_dir, prune_system, prune_volume, prune_duration
#
# @groups security insecure_registries, users
#
# @groups registry registry, upstream_repo
#
# @groups cadvisor cadvisor_image
#
# @groups instances instances
#
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
  String                               $prune_duration      = '30'
) inherits ::role::virtualization {

  $_allow_docker = lookup('common::network::firewall::allow_docker', Boolean, undef, false)
  confine(!$_allow_docker, 'This role needs the setting `common::network::firewall::allow_docker` to be enabled!')
  confine($manage_compose, !$compose_instances, 'A compose instance must be present if managing compose')
  confine($bip, $bridge_interface, '`$bip` and `$bridge_interface` cannot be set simultaneously')

  contain profile::virtualization::docker
}
