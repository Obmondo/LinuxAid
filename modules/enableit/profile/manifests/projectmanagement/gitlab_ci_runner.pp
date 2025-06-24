#
# $redirect_http_to_https : only makes gitlab listen on port 80 (only relevant if $external_url start with https:// - which makes it not listen on port 80 normally). it actually won't redirect unless external_url IS set to https://
#
class profile::projectmanagement::gitlab_ci_runner (
  Optional[Enum['docker']]         $executor         = 'docker',
  Optional[Eit_types::DockerImage] $docker_image     = 'ubuntu/noble',
  Hash                             $runners          = {},
  Integer[1,default]               $concurrency      = 2,
  Hash                             $runners_defaults = {},
  Boolean                          $manage_repo      = true,
  Boolean                          $manage_docker    = true,
  Integer[0,default]               $check_interval   = 30,
  Stdlib::Absolutepath             $gitlab_runner_home = '/var/lib/gitlab-runner',
) {

  if $manage_docker {
    contain role::virtualization::docker

    user { 'gitlab-runner':
      groups     => 'docker',
      home       => $gitlab_runner_home,
      managehome => true,
    }
  }

  class { '::gitlab_ci_runner':
    concurrent      => $concurrency,
    manage_docker   => false,
    manage_repo     => $manage_repo,
    runners         => $runners,
    runner_defaults => $runners_defaults,
  }

  file { $gitlab_runner_home:
    ensure  => directory,
    owner   => 'gitlab-runner',
    require => User['gitlab-runner'],
  }

  file { '/etc/systemd/system/gitlab-runner.service.d/gitlab-runner-execstart.conf':
    ensure => 'absent',
    notify => [
      Exec['daemon-reload'],
    ],
    before => Class['gitlab_ci_runner'],
  }

  # https://blog.matt.wf/gitlab-runner-clean-up-caches/
  # Remove gitlab-runner cache on every Sunday at 4:00 am
  cron::weekly { 'remove_gitlab_cache_container_weekly':
    hour    => '4',
    user    => 'root',
    command => 'chronic docker ps -q -a --filter exited=0 --filter name=runner-.*-project-.*-concurrent-.*-cache-.*$ | xargs --no-run-if-empty docker rm ', # lint:ignore:140chars
  }
}
