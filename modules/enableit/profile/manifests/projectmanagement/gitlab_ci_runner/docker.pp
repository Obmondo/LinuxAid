# Handles all docker runner infrastructure:
#   - docker user setup and group membership
#   - gitlab-runner home directory
#   - weekly cache container cleanup
#   - firewall pre-condition check
#
class profile::projectmanagement::gitlab_ci_runner::docker {
  confine(!lookup('common::network::firewall::allow_docker', Optional[Boolean], undef, undef),
          '`common::network::firewall::allow_docker` must be `true`')

  $docker_user        = 'gitlab-runner'
  $gitlab_runner_home = '/var/lib/gitlab-runner'

  user { $docker_user:
    groups     => 'docker',
    home       => $gitlab_runner_home,
    managehome => true,
  }

  # Remove legacy cron job — replaced by systemd timer below
  file { '/etc/cron.d/remove_gitlab_cache_container_weekly':
    ensure => absent,
  }

  # https://blog.matt.wf/gitlab-runner-clean-up-caches/
  # Remove gitlab-runner cache containers every Sunday at 4:00 am
  $_timer = @("EOT")
    [Unit]
    Description=Weekly cleanup of GitLab Runner cache containers

    [Timer]
    OnCalendar=Sun *-*-* 04:00:00
    Persistent=true

    [Install]
    WantedBy=timers.target
    | EOT

  $_service = @("EOT")
    [Unit]
    Description=Remove exited GitLab Runner cache containers

    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c 'docker ps -q -a --filter exited=0 --filter "name=runner-.*-project-.*-concurrent-.*-cache-.*$$" | xargs --no-run-if-empty docker rm'
    | EOT

  systemd::timer { 'gitlab-runner-cache-cleanup.timer':
    timer_content   => $_timer,
    service_content => $_service,
    active          => true,
    enable          => true,
  }
}
