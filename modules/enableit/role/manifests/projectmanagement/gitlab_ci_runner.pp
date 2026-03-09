
# @summary Class for managing the GitLab CI Runner
#
# @param shell A list of shell executor entries, each with a user and optional settings.
#
# @param docker A hash of settings for docker executor runners.
#              Includes 'concurrency' to control how many docker runner instances are registered.
#
# @param __blendable An internal parameter.
#
# @groups configuration shell, docker.
#
# @groups internal __blendable.
#
class role::projectmanagement::gitlab_ci_runner (
  Array[Eit_types::Gitlab::Runner::Shell]     $shell       = [],
  Optional[Eit_types::Gitlab::Runner::Config] $docker      = undef,
  Boolean                                     $__blendable,
) inherits ::role::projectmanagement {

  class { 'profile::projectmanagement::gitlab_ci_runner':
    shell  => $shell,
    docker => $docker,
  }
}
