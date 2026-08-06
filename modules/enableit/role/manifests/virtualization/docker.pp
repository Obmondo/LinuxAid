# @summary Docker role class
#
# @param docker_lib_dir The directory for Docker library files. Defaults to '/var/lib/docker'.
#
# @param fixed_cidr The fixed CIDR for the Docker network. Defaults to undef.
#
# @param instances The Docker instances configuration. Defaults to an empty hash.
#
# @param compose_instances The Docker Compose instances configuration. Defaults to an empty hash.
#
# @param networks The networks configuration for Docker. Defaults to an empty hash.
#
# @param dns The DNS configuration for Docker. Defaults to undef.
#
# @param dns_search The DNS search domains for Docker. Defaults to undef.
#
# @param insecure_registries The list of insecure registries. Defaults to undef.
#
# @param registry The registry configuration for Docker. Defaults to an empty hash.
#
# @param upstream_repo Whether to use the upstream repository. Defaults to true.
#
# @param cadvisor_image The cAdvisor image to use. Defaults to 'ghcr.io/google/cadvisor:0.56.2'.
#
# @param prune_duration The parameter prune_duration specifies the duration in days for which unused Docker resources will be retained before being pruned. Defaults to '30'.
#
# @groups network fixed_cidr, dns, dns_search, networks
#
# @groups compose compose_instances
#
# @groups storage docker_lib_dir, prune_duration
#
# @groups security insecure_registries
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
  Hash                                 $instances           = {},
  Eit_types::Docker::ComposeInstances  $compose_instances   = {},
  Hash                                 $networks            = {},
  Optional[Array[Stdlib::IP::Address]] $dns                 = undef,
  Optional[Array[Eit_types::Domain]]   $dns_search          = undef,
  Optional[Array[Eit_types::FQDNPort]] $insecure_registries = undef,
  Hash[Eit_types::Domain, Hash]        $registry            = {},
  Boolean                              $upstream_repo       = true,
  String                               $cadvisor_image      = 'ghcr.io/google/cadvisor:0.56.2',
  String                               $prune_duration      = '30'
) inherits ::role::virtualization {

  $_allow_docker = lookup('common::network::firewall::allow_docker', Boolean, undef, false)
  confine(!$_allow_docker, 'This role needs the setting `common::network::firewall::allow_docker` to be enabled!')

  contain profile::virtualization::docker
}
