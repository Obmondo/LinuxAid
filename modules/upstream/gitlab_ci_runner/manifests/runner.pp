# @summary This module installs and configures Gitlab CI Runners.
#
# @example Simple runner registration
#   gitlab_ci_runner::runner { example_runner:
#     config => {
#       'registration-token' => 'gitlab-token',
#       'url'                => 'https://gitlab.com',
#       'tag-list'           => 'docker,aws',
#     },
#   }
#
# @param config
#   Hash with configuration options.
#   See https://docs.gitlab.com/runner/configuration/advanced-configuration.html for all possible options.
# @param ensure
#   If the runner should be 'present' or 'absent'. Will register/unregister the runner from Gitlab.
# @param runner_name
#   The name of the runner.
# @param binary
#   The name of the Gitlab runner binary.
#
define gitlab_ci_runner::runner (
  Hash                      $config,
  Enum['present', 'absent'] $ensure      = 'present',
  String[1]                 $runner_name = $title,
  String[1]                 $binary      = 'gitlab-runner',
) {
  # Ensure we have a unique runner name
  $_config = { name => $runner_name } + $config
  $_name   = $_config['name']

  # To be able to use all parameters as command line arguments,
  # we have to transform the configuration into something the gitlab-runner
  # binary accepts:
  # * Always prefix the options with '--'
  # * Always join option names and values with '='
  #
  # In the end, flatten thewhole array and join all elements with a space as delimiter
  $__config = $_config.map |$item| {
    # Ensure all keys use '-' instead of '_'. Needed for e.g. build_dir.
    $key = regsubst($item[0], '_', '-', 'G')

    # If the value ($item[1]) is an Array multiple elements are added for each item
    if $item[1] =~ Array {
      $item[1].map |$nested| {
        "--${key}=${nested}"
      }
    } else {
      "--${key}=${item[1]}"
    }
  }.flatten.join(' ')

  if $ensure == 'absent' {
    # Execute gitlab ci multirunner unregister
    exec {"Unregister_runner_${title}":
      command => "/usr/bin/${binary} unregister -n ${_name}",
      onlyif  => "/bin/grep -F \'${_name}\' /etc/gitlab-runner/config.toml",
    }
  } else {
    # Execute gitlab ci multirunner register
    exec {"Register_runner_${title}":
      command => "/usr/bin/${binary} register -n ${__config}",
      unless  => "/bin/grep -F \'${_name}\' /etc/gitlab-runner/config.toml",
    }
  }
}
