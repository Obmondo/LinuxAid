# Gitlab Runner profile
#
class profile::projectmanagement::gitlab_ci_runner (
  Eit_types::UserName               $run_as_user      = $role::projectmanagement::gitlab_ci_runner::run_as_user,
  Integer[1,10]                     $concurrency      = $role::projectmanagement::gitlab_ci_runner::concurrency,
  Eit_types::Gitlab::Runner         $runners          = $role::projectmanagement::gitlab_ci_runner::runners,
  Eit_types::Gitlab::Runner::Config $runner_defaults  = $role::projectmanagement::gitlab_ci_runner::runner_defaults,
) {

  $runners.each |$runner_name, $config| {
    $_config = $runner_defaults + $config

    confine(!$_config['url'], 'Gitlab Server URL is mandatory')
    confine(!$_config['registration-token'], 'Gitlab Registration token is mandatory')
  }

  # Find out if there is any docker or shell executor from the
  # given runner configs
  $docker_executor = $runners.each |$runner_name, $config| {
    $_config = $runner_defaults + $config

    # Make sure we allow Docker rules in the firewall
    confine($_config['executor'] == 'docker', !lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
            '`common::network::firewall::allow_docker` must be `true`')

    $_config['executor'] == 'docker'
  }

  $shell_executor = $runners.each |$runner_name, $config| {
    $_config = $runner_defaults + $config
    $_config['executor'] == 'shell'
  }

  if $docker_executor {
    contain role::virtualization::docker

    $gitlab_runner_home = '/var/lib/gitlab-runner'

    user { 'gitlab-runner':
      groups     => 'docker',
      home       => $gitlab_runner_home,
      managehome => true,
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
  if $shell_executor and $run_as_user != 'gitlab-runner' {

    # NOTE: the binary path is static, copied directly from upstream.
    # we can try getvar or something, leaving it for next time
    exec { "/usr/local/bin/gitlab-runner install -u ${run_as_user}":
      creates => "/etc/systemd/system/gitlab-runner-${run_as_user}.service",
    }

    service { "gitlab-runner-${run_as_user}.service":
      ensure => running,
      enable => true,
    }
  }

  file { $gitlab_runner_home:
    ensure  => directory,
    owner   => 'gitlab-runner',
    require => User['gitlab-runner'],
  }

  class { '::gitlab_ci_runner':
    concurrent      => $concurrency,
    manage_docker   => false,
    manage_repo     => true,
    runners         => $runners,
    runner_defaults => $runner_defaults,
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
