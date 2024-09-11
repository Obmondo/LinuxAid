#
# $redirect_http_to_https : only makes gitlab listen on port 80 (only relevant if $external_url start with https:// - which makes it not listen on port 80 normally). it actually won't redirect unless external_url IS set to https://
#
class role::projectmanagement::gitlab_ci_runner (
  Eit_types::URL                   $url,
  String                           $token,
  Optional[Enum['docker']]         $executor         = 'docker',
  Optional[Eit_types::DockerImage] $docker_image     = 'ubuntu/xenial',
  Integer[1,default]               $concurrency      = 2,
  Hash                             $runners          = {},
  Hash                             $runners_defaults = {},
  Boolean                          $manage_repo      = true,
  Boolean                          $manage_docker    = true,
  Integer[0,default]               $check_interval   = 30,
  Boolean                          $__blendable,
) inherits ::role::projectmanagement {

  confine($executor == 'docker', !$docker_image, "`docker_image` needs to be set if `executor` set to 'docker'")

  # Make sure we allow Docker rules in the firewall
  confine(!lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
          '`common::network::firewall::allow_docker` must be `true`')

  class { 'profile::projectmanagement::gitlab_ci_runner':
    url              => $url,
    token            => $token,
    executor         => $executor,
    docker_image     => $docker_image,
    runners          => $runners,
    concurrency      => $concurrency,
    runners_defaults => $runners_defaults,
    manage_repo      => $manage_repo,
    manage_docker    => $manage_docker,
    check_interval   => $check_interval,
  }
}
