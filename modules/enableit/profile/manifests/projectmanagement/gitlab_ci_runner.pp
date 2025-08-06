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
  Integer[1,10]                     $concurrency      = $role::projectmanagement::gitlab_ci_runner::concurrency,
  Eit_types::Gitlab::Runner         $runners          = $role::projectmanagement::gitlab_ci_runner::runners,
  Eit_types::Gitlab::Runner::Config $runner_defaults  = $role::projectmanagement::gitlab_ci_runner::runner_defaults,
  Eit_types::IPPort                 $listen_address   = '127.254.254.254:63384',
) {

  contain monitor::system::service::gitlab_runner

  $runners.each |$runner_name, $config| {
    $_config = $runner_defaults + $config

    confine($_config['url'], 'Gitlab Server URL is mandatory')
    confine($_config['registration-token'], 'Gitlab Registration token is mandatory')
  }

  # Find out if there is any docker or shell executor from the
  # given runner configs
  $docker_executor = $runners.any |$runner_name, $config| {
    $_config = $runner_defaults + $config

    # Make sure we allow Docker rules in the firewall
    confine($_config['executor'] == 'docker', !lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
            '`common::network::firewall::allow_docker` must be `true`')

    $_config['executor'] == 'docker'
  }

  $shell_executor = $runners.any |$runner_name, $config| {
    $_config = $runner_defaults + $config
    $_config['executor'] == 'shell'
  }

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
  # but if the user is not gitlab-runner, then we will have to handle it ourselves.
  # which means, create user and service file for now,
  # lets just manage the service file, handling user creation is for later.
  if $shell_executor {

    $runners.each |$runner_name, $config| {
      $_config = $runner_defaults + $config

      $run_as_user = $_config['run_as_user']

      $working_directory = $_config['working_directory'] ? {
        under   => '/local',
        default => $_config['working_directory'],
      }

      $service_name = "gitlab-runner-${run_as_user}"

      # We will not setup gitlab-runner service, since thats the default one.
      if $run_as_user == 'gitlab-runner' {
        next()
      }

      # NOTE: the binary path is static
      # Tested only on Redhat family
      exec { "/usr/bin/gitlab-runner install --service ${service_name} --working-directory ${working_directory} --user ${run_as_user}":
        creates => "/etc/systemd/system/${service_name}",
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

    if !$docker_executor {
      service { 'gitlab-runner.service':
        ensure => stopped,
        enable => false,
      }
    }
  }

  class { '::gitlab_ci_runner':
    concurrent      => $concurrency,
    manage_docker   => false,
    manage_repo     => true,
    runners         => $runners,
    runner_defaults => $runner_defaults,
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
