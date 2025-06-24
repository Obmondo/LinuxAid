
# @summary Class for managing the GitLab CI Runner
#
# @param url The URL for the GitLab instance.
#
# @param user The username for the Gitlab Runner should run as, works only with shell executor. Defaults to 'gitlab-runner'
#
# @param executor The executor type for the runner. Defaults to 'docker'.
#
# @param docker_image The Docker image to use for the runner. Defaults to 'ubuntu/noble'.
#
# @param concurrency The number of concurrent jobs to run. Defaults to 2.
#
# @param runners A hash of runner-specific configurations.
#
# @param runner_defaults A hash of default configurations for the runners.
#
# @param manage_repo Flag to manage the repository settings. Defaults to true.
#
# @param $__blendable
# An internal parameter.
#
class role::projectmanagement::gitlab_ci_runner (
  Eit_types::UserName               $run_as_user     = 'gitlab-runner',
  Integer[1,10]                     $concurrency     = 2,
  Eit_types::Gitlab::Runner         $runners         = {},
  Eit_types::Gitlab::Runner::Config $runner_defaults = {},
  Boolean                           $__blendable,
) inherits ::role::projectmanagement {

  # Make sure we allow Docker rules in the firewall
  confine(!lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
          '`common::network::firewall::allow_docker` must be `true`')

  class { 'profile::projectmanagement::gitlab_ci_runner':
    run_as_user     => $run_as_user,
    runners         => $runners,
    concurrency     => $concurrency,
    runner_defaults => $runner_defaults,
  }
}
