# Gitlab Runner profile
#
# Supports:
# If docker or shell executor is there with gitlab-runner user
# If docker is with gitlab-runner and shell executor with diff user
# If just shell executor is there with gitlab-runner
# If shell executor is there with diff runner user
#
# Not Supported:
# docker with diff user is not supported, since it does not make sense.
# Multiple runner which can talk to diff gitlab instance.
#
class profile::projectmanagement::gitlab_ci_runner (
  Array[Eit_types::Gitlab::Runner::Shell]     $shell          = $role::projectmanagement::gitlab_ci_runner::shell,
  Optional[Eit_types::Gitlab::Runner::Config] $docker         = $role::projectmanagement::gitlab_ci_runner::docker,
  Eit_types::IPPort                           $listen_address = '127.254.254.254:63384',
) {

  contain monitor::system::service::gitlab_runner
  include common::monitor::exporter::gitlab_runner

  $hostname = $facts['networking']['hostname']

  # concurrency for docker runners comes from docker settings; defaults to 1
  $_docker_concurrency = $docker ? {
    undef   => 0,
    default => $docker['concurrency'] ? { undef => 1, default => $docker['concurrency'] },
  }

  # Build docker runners: auto-generate $_docker_concurrency numbered runners.
  # Strip 'concurrency' from the runner config — it is not a valid runner-level key.
  $docker_runners = $docker ? {
    undef   => {},
    default => Hash(range(1, $_docker_concurrency).map |$i| {
      ["${hostname}_runner${sprintf('%02d', $i)}", ($docker - 'concurrency') + { 'executor' => 'docker' }]
    }),
  }

  # Separate shell entries:
  #   default entries (no user, or user == 'gitlab-runner') → main config.toml + default service
  #   custom entries (explicit non-default user) → per-user config file + dedicated service
  $default_shell_entries = $shell.filter |$entry| {
    $entry['user'] == undef or $entry['user'] == 'gitlab-runner'
  }
  $custom_shell_entries = $shell.filter |$entry| {
    $entry['user'] != undef and $entry['user'] != 'gitlab-runner'
  }

  # Each shell entry supports an optional 'concurrency' in settings to register
  # multiple runner instances. Strip 'concurrency' from the runner config passed
  # to ::gitlab_ci_runner as it is not a valid runner-level key.
  # Runners are named <hostname>_shell_<NN> for the default user.
  $default_shell_runners = Hash(
    $default_shell_entries.reduce([]) |$memo, $entry| {
      $_settings    = $entry['settings'] ? { undef => {}, default => $entry['settings'] }
      $_concurrency = $_settings['concurrency'] ? { undef => 1, default => $_settings['concurrency'] }
      $memo + range(1, $_concurrency).map |$i| {
        ["${hostname}_shell_${sprintf('%02d', $i)}", ($_settings - 'concurrency') + { 'executor' => 'shell' }]
      }
    }
  )

  # Custom-user runners are named <hostname>_shell_<user>_<NN> for disambiguation.
  $custom_shell_runners = Hash(
    $custom_shell_entries.reduce([]) |$memo, $entry| {
      $_settings    = $entry['settings'] ? { undef => {}, default => $entry['settings'] }
      $_concurrency = $_settings['concurrency'] ? { undef => 1, default => $_settings['concurrency'] }
      $memo + range(1, $_concurrency).map |$i| {
        ["${hostname}_shell_${entry['user']}_${sprintf('%02d', $i)}",
          ($_settings - 'concurrency') + { 'executor' => 'shell', 'run_as_user' => $entry['user'] }]
      }
    }
  )

  # Main runners passed to ::gitlab_ci_runner (docker + default-user shell)
  $main_runners = $docker_runners + $default_shell_runners

  # Validate all runners (main + custom) have the required fields
  ($main_runners + $custom_shell_runners).each |$runner_name, $config| {
    confine(!$config['url'], 'Gitlab Server URL is mandatory')
    confine(!$config['registration-token'], 'Gitlab Registration token is mandatory')
  }

  $docker_executor = $docker != undef

  # Make sure we allow Docker rules in the firewall
  if $docker_executor {
    confine(!lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
            '`common::network::firewall::allow_docker` must be `true`')
  }

  # shell_executor is true only when there are custom-user runners that need
  # their own service; default-user runners are handled by ::gitlab_ci_runner
  $shell_executor = !$custom_shell_entries.empty

  if $docker_executor {
    contain role::virtualization::docker

    $user = 'gitlab-runner'
    $gitlab_runner_home = '/var/lib/gitlab-runner'

    user { $user:
      groups     => 'docker',
      home       => $gitlab_runner_home,
      managehome => true,
    }

    # NOTE: this does not matter much, since the container will be dropping files to data-dir
    # which is set in docker daemon
    file { $gitlab_runner_home:
      ensure  => directory,
      owner   => $user,
      require => User[$user],
    }

    # https://blog.matt.wf/gitlab-runner-clean-up-caches/
    # Remove gitlab-runner cache on every Sunday at 4:00 am
    cron::weekly { 'remove_gitlab_cache_container_weekly':
      hour    => '4',
      user    => 'root',
      command => 'chronic docker ps -q -a --filter exited=0 --filter name=runner-.*-project-.*-concurrent-.*-cache-.*$ | xargs --no-run-if-empty docker rm ', # lint:ignore:140chars
    }
  }

  # NOTE: gitlab-runner user is always created by post-install script
  # and along with this the systemd service is also created.
  # For custom users we create a separate config file and service so the
  # runner process runs as that user and reads its own isolated config.
  if $shell_executor {

    $custom_shell_entries.each |$entry| {
      $run_as_user  = $entry['user']
      $_settings    = $entry['settings'] ? { undef => {}, default => $entry['settings'] }
      $_concurrency = $_settings['concurrency'] ? { undef => 1, default => $_settings['concurrency'] }

      $working_directory = $_settings['working_directory'] ? {
        undef   => '/local',
        default => $_settings['working_directory'],
      }

      $service_name = "gitlab-runner-${run_as_user}"
      $config_file  = "/etc/gitlab-runner/config-${run_as_user}.toml"

      # Global options for the per-user config file.
      # check_interval and shutdown_timeout are global-only settings — they live
      # in the config file header and must be stripped from the runner-level config.
      $_global_options = {
        concurrent         => $_concurrency,
        check_interval     => $_settings['check_interval'] ? { undef => 0, default => $_settings['check_interval'] },
        shutdown_timeout   => $_settings['shutdown_timeout'] ? { undef => 30, default => $_settings['shutdown_timeout'] },
        connection_max_age => $_settings['connection_max_age'] ? { undef => '15m0s', default => $_settings['connection_max_age'] },
      }

      # Create a dedicated config file for this user's runner service.
      concat { $config_file:
        ensure         => present,
        owner          => 'root',
        group          => 'root',
        mode           => '0444',
        ensure_newline => true,
        require        => Class['gitlab_ci_runner::install'],
      }

      concat::fragment { "${config_file} - header":
        target  => $config_file,
        order   => '00',
        content => "# MANAGED BY PUPPET\n${gitlab_ci_runner::to_toml($_global_options)}",
      }

      # Register $_concurrency runner instances, each with a unique name, and write
      # them all into this user's config file (mimic gitlab_ci_runner::runner).
      range(1, $_concurrency).each |$i| {
        $_runner_name   = "${hostname}_shell_${run_as_user}_${sprintf('%02d', $i)}"
        # Strip fields that are global config options, not runner-level keys
        $_runner_config = ($_settings - ['concurrency', 'check_interval', 'shutdown_timeout', 'connection_max_age']) + {
          'executor' => 'shell',
          'name'     => $_runner_name,
        }

        $register_additional_options = $_runner_config
          .filter |$item| { $item[0] =~ Gitlab_ci_runner::Register_parameters }
          .reduce({}) |$memo, $item| { $memo + { regsubst($item[0], '-', '_', 'G') => $item[1] } }

        $deferred_token = Deferred('gitlab_ci_runner::register_to_file', [
          $_runner_config['url'],
          $_runner_config['registration-token'],
          $_runner_name,
          $register_additional_options,
          undef,
          undef,
        ])

        $_runner_config_for_file = ($_runner_config - (Array(Gitlab_ci_runner::Register_parameters) + 'registration-token')) + { 'token' => $deferred_token }

        $fragment_content = Deferred('gitlab_ci_runner::to_toml', [{ runners => [$_runner_config_for_file] }])

        concat::fragment { "${config_file} - ${run_as_user} - ${i}":
          target  => $config_file,
          order   => sprintf('%02d', $i + 1),
          content => $fragment_content,
        }
      }

      # Install a dedicated systemd service that runs as $run_as_user and
      # reads the per-user config file created above.
      # NOTE: the binary path is static; tested only on Redhat family
      exec { "/usr/bin/gitlab-runner install --service ${service_name} --config ${config_file} --working-directory ${working_directory} --user ${run_as_user}":
        creates => "/etc/systemd/system/${service_name}.service",
        require => Class['gitlab_ci_runner::install'],
      }

      file { [
        $working_directory,
        "${working_directory}/${run_as_user}",
      ]:
        ensure => directory,
        owner  => $run_as_user,
      }

      service { $service_name:
        ensure => running,
        enable => true,
      }
    }

    # Stop the default service only when no runners use it
    # (i.e. no docker runners and no default-user shell runners)
    if $main_runners.empty {
      service { 'gitlab-runner.service':
        ensure => stopped,
        enable => false,
      }
    }
  }

  class { '::gitlab_ci_runner':
    # concurrent = total runners in the main config (docker + default-user shell).
    # Pass undef when empty so the upstream module uses its own default.
    concurrent      => $main_runners.empty ? { true => undef, false => $main_runners.size },
    manage_docker   => false,
    manage_repo     => true,
    runners         => $main_runners,
    runner_defaults => {},
    # NOTE: only default gitlab-runner metrics will be scraped.
    # TODO: add support for this even for shell executor
    listen_address  => $listen_address,
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
