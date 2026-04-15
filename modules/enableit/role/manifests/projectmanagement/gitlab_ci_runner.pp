
# @summary Class for managing the GitLab CI Runner
#
# @param url
#   GitLab instance URL shared by all runners on this node.
#
# @param registration_token
#   GitLab runner registration token shared by all runners on this node.
#
# @param concurrent
#   Global concurrent job limit across all runners on this node (config.toml `concurrent`).
#
# @param docker_defaults
#   Default docker settings applied to every docker runner. Per-runner values override these.
#   Example (Hiera):
#     role::projectmanagement::gitlab_ci_runner::docker_defaults:
#       image: 'ubuntu:22.04'
#       tls_verify: false
#       privileged: false
#       volumes:
#         - '/cache'
#
# @param docker_runners
#   A hash of docker runners keyed by runner name. Each entry creates a [[runners]]
#   section with executor = docker. Values here override docker_defaults.
#   Example (Hiera):
#     role::projectmanagement::gitlab_ci_runner::docker_runners:
#       runner01: {}           # uses all docker_defaults
#       runner02:
#         image: 'alpine:3.18' # overrides just the image
#
# @param shell_runners
#   A hash of shell runners keyed by the Linux user they should run as.
#   Each entry configures a dedicated systemd service and config file for
#   that user so that shell jobs run with the correct OS identity.
#   Example (Hiera):
#     role::projectmanagement::gitlab_ci_runner::shell_runners:
#       deploy:
#         working_directory: '/local'
#       build: {}
#
# @param __blendable An internal parameter.
#
# @groups configuration url, registration_token, concurrent, docker_defaults, docker_runners, shell_runners.
#
# @groups internal __blendable.
#
class role::projectmanagement::gitlab_ci_runner (
  Stdlib::HTTPSUrl                          $url,
  String                                    $registration_token,
  Integer[1]                                $concurrent,
  Eit_types::Gitlab::Runner::Docker         $docker_runners,
  Eit_types::Gitlab::Runner::Docker::Defaults $docker_defaults,
  Eit_types::Gitlab::Runner::Shell          $shell_runners,
  Boolean                                   $__blendable,
) inherits ::role::projectmanagement {

  unless $docker_runners.empty {
    contain role::virtualization::docker
  }

  class { 'profile::projectmanagement::gitlab_ci_runner':
    url                => $url,
    registration_token => $registration_token,
    concurrent         => $concurrent,
    docker_runners     => $docker_runners,
    docker_defaults    => $docker_defaults,
    shell_runners      => $shell_runners,
  }
}
