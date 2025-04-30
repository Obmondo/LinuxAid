
# @summary Class for managing the GitLab CI Runner
#
# @param url The URL for the GitLab instance.
#
# @param token The registration token for the runner.
#
# @param executor The executor type for the runner. Defaults to 'docker'.
#
# @param docker_image The Docker image to use for the runner. Defaults to 'ubuntu/xenial'.
#
# @param concurrency The number of concurrent jobs to run. Defaults to 2.
#
# @param runners A hash of runner-specific configurations.
#
# @param runners_defaults A hash of default configurations for the runners.
#
# @param manage_repo Flag to manage the repository settings. Defaults to true.
#
# @param manage_docker Flag to manage Docker settings. Defaults to true.
#
# @param check_interval The interval in seconds for checking the GitLab server for new jobs. Defaults to 30.
#
# @param $__blendable
# An internal parameter.
#
# @param __encrypt The list of params, which needs to be encrypted
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

  Eit_types::Encrypt::Params $__encrypt = [
    'token',
  ]

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
