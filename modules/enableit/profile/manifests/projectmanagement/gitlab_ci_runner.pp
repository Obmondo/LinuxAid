# Gitlab Runner profile
#
# Supports:
# - Docker runners (running as the gitlab-runner user, via the default service)
# - Shell runners running as a different OS user, each with their own
#   dedicated systemd service and config file
# - Both docker and shell runners simultaneously
#
# Not Supported:
# - Docker runners with a different user (does not make sense)
#
class profile::projectmanagement::gitlab_ci_runner (
  Stdlib::HTTPSUrl                          $url              = $role::projectmanagement::gitlab_ci_runner::url,
  String                                    $registration_token = $role::projectmanagement::gitlab_ci_runner::registration_token,
  Integer[1]                                $concurrent       = $role::projectmanagement::gitlab_ci_runner::concurrent,
  Eit_types::Gitlab::Runner::Docker         $docker_runners   = $role::projectmanagement::gitlab_ci_runner::docker_runners,
  Eit_types::Gitlab::Runner::Docker::Defaults $docker_defaults = $role::projectmanagement::gitlab_ci_runner::docker_defaults,
  Eit_types::Gitlab::Runner::Shell          $shell_runners    = $role::projectmanagement::gitlab_ci_runner::shell_runners,
  Eit_types::IPPort                         $listen_address   = '127.254.254.254:63384',
) {

  contain monitor::system::service::gitlab_runner
  include common::monitor::exporter::gitlab_runner

  if !$docker_runners.empty {
    contain profile::projectmanagement::gitlab_ci_runner::docker
  }

  # Shell runners for the default gitlab-runner user are passed to the upstream
  # module — no separate service or exec needed.
  # Shell runners for any other user go through the defined type which creates
  # a dedicated config file and systemd service.
  $default_shell_runners = $shell_runners.filter |$user, $_| { $user == 'gitlab-runner' }
  $custom_shell_runners  = $shell_runners.filter |$user, $_| { $user != 'gitlab-runner' }

  $custom_shell_runners.each |$run_as_user, $settings| {
    profile::projectmanagement::gitlab_ci_runner::shell { $run_as_user:
      url                => $url,
      registration_token => $registration_token,
      working_directory  => $settings['working_directory'],
      concurrent_runners => pick($settings['concurrent_runners'], 1),
    }
  }

  # Build the upstream runners hash:
  #   - docker runners (if configured), each as a nested sub-hash
  #   - default-user shell runners passed directly
  $docker_upstream = Hash($docker_runners.map |$runner_name, $settings| {
    $merged = $docker_defaults + $settings
    [$runner_name, delete_undef_values({
      'url'                => $url,
      'registration-token' => $registration_token,
      'executor'           => 'docker',
      'ca_file'            => $merged['ca_file'],
      'docker'             => delete_undef_values({
        'image'         => $merged['image'],
        'tls_verify'    => $merged['tls_verify'],
        'privileged'    => $merged['privileged'],
        'disable_cache' => $merged['disable_cache'],
        'volumes'       => $merged['volumes'],
      }),
    })]
  })

  # Default-user shell runners. Without `runners`, a single runner named
  # shell-gitlab-runner is registered with the role's registration_token.
  # With `runners`, one [[runners]] entry is created per key; a runner with
  # its own `token` (a glrt- authentication token created in GitLab) is used
  # as-is, otherwise it is registered with the registration_token.
  # builds_dir/cache_dir are placed under working_directory when it is set.
  # ca_file is used by the upstream module to verify GitLab while registering.
  $shell_upstream = $default_shell_runners.reduce({}) |$memo, $entry| {
    $settings = $entry[1]
    $_workdir = $settings['working_directory']

    if $_workdir {
      file { [$_workdir, "${_workdir}/builds", "${_workdir}/cache"]:
        ensure  => directory,
        owner   => 'gitlab-runner',
        group   => 'gitlab-runner',
        mode    => '0750',
        require => Class['gitlab_ci_runner::install'],
      }
    }

    $_dirs = $_workdir ? {
      undef   => {},
      default => {
        'builds_dir' => "${_workdir}/builds",
        'cache_dir'  => "${_workdir}/cache",
      },
    }

    $_runners = pick($settings['runners'], { 'shell-gitlab-runner' => {} })

    $memo + Hash($_runners.map |$runner_name, $runner| {
      $_auth = $runner['token'] ? {
        undef   => { 'registration-token' => $registration_token },
        default => { 'token' => $runner['token'] },
      }
      [$runner_name, delete_undef_values({
        'url'         => $url,
        'executor'    => 'shell',
        'ca_file'     => $settings['ca_file'],
        'environment' => $runner['environment'],
        'limit'       => $runner['limit'],
      }) + $_dirs + $_auth]
    })
  }

  class { '::gitlab_ci_runner':
    concurrent     => $concurrent,
    manage_docker  => false,
    manage_repo    => true,
    runners        => $docker_upstream + $shell_upstream,
    # NOTE: only default gitlab-runner metrics will be scraped.
    # TODO: add support for this even for shell executor
    listen_address => $listen_address,
  }

  # TODO: Remove this block entirely ?
  # NOTE: This seems redundent to me, maybe in future one can look and remove it entirely.
  file { '/etc/systemd/system/gitlab-runner.service.d/gitlab-runner-execstart.conf':
    ensure => 'absent',
    notify => [
      Exec['daemon-reload'],
    ],
    before => Class['gitlab_ci_runner'],
  }
}
