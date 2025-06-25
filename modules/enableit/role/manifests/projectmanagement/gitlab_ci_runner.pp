
# @summary Class for managing the GitLab CI Runner
#
# @param run_as_user The username for the Gitlab Runner should run as, works only with shell executor. Defaults to 'gitlab-runner'
#
# @param concurrency The number of concurrent jobs to run. Defaults to 2.
#
# @param runners A hash of runner-specific configurations.
#
# @param runner_defaults A hash of default configurations for the runners.
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

  class { 'profile::projectmanagement::gitlab_ci_runner':
    run_as_user     => $run_as_user,
    runners         => $runners,
    concurrency     => $concurrency,
    runner_defaults => $runner_defaults,
  }
}
