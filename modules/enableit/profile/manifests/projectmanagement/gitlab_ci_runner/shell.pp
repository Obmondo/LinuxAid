# Defined type for a custom-user shell runner.
# Title is the OS user the runner service will run as (never 'gitlab-runner').
#
# Each declaration creates:
#   - /etc/gitlab-runner/config-<user>.toml       (dedicated config file)
#   - gitlab-runner-<user>.service                (dedicated systemd service)
#   - gitlab-runner-<user>-register.service       (oneshot registration service)
#
# Shell runners running as the default 'gitlab-runner' user are handled by the
# upstream ::gitlab_ci_runner class and do not go through this defined type.
#
# Each runner gets its own config file via --config, keeping shell and docker
# jobs fully isolated.
#
# NOTE: binary path is static; tested only on RedHat family.
# NOTE: if the registration-token changes, remove the runner's [[runners]]
#       entry from the config file to trigger re-registration on the next run.
#
define profile::projectmanagement::gitlab_ci_runner::shell (
  Stdlib::HTTPSUrl           $url,
  String                     $registration_token,
  Optional[Stdlib::Unixpath] $working_directory  = undef,
  Integer[1]                 $concurrent_runners = 1,
) {
  $run_as_user        = $title
  $config_path        = "/etc/gitlab-runner/config-${run_as_user}.toml"
  $service_name       = "gitlab-runner-${run_as_user}"
  $_working_directory = pick($working_directory, '/local')

  file { $config_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    replace => false,
    content => "# MANAGED BY PUPPET\n",
  }

  file { [
    $_working_directory,
    "${_working_directory}/${run_as_user}",
  ]:
    ensure => directory,
    owner  => $run_as_user,
  }

  # Long-running runner daemon service
  $_service = @("EOT")
    [Unit]
    Description=GitLab Runner (${run_as_user})
    After=syslog.target network.target
    ConditionFileIsExecutable=/usr/bin/gitlab-runner

    [Service]
    ExecStart=/usr/bin/gitlab-runner run \
      --working-directory ${_working_directory}/${run_as_user} \
      --config ${config_path} \
      --service ${service_name} \
      --user ${run_as_user}
    Restart=always
    RestartSec=120

    [Install]
    WantedBy=multi-user.target
    | EOT

  $_hostname = $facts['networking']['hostname']
  $_names = range(1, $concurrent_runners).map |$i| {
    "${_hostname}_${run_as_user}_shell_runner_${i}"
  }
  $_register_cmds = $_names.map |$n| {
    "grep -q \"name = \\\"${n}\\\"\" ${config_path} || /usr/bin/gitlab-runner register --non-interactive --config ${config_path} --url ${url} --registration-token ${registration_token} --executor shell --name ${n} --tag-list shell --run-untagged=false"
  }.join(' && ')

  systemd::unit_file { "${service_name}.service":
    content => $_service,
    require => File[$config_path, $_working_directory],
  }

  # One oneshot register unit; registers each concurrent runner only if its
  # name is not already present in the config.
  $_register_service = @("EOT")
    [Unit]
    Description=Register GitLab Runners for ${run_as_user}
    After=network-online.target
    Wants=network-online.target
    ConditionFileIsExecutable=/usr/bin/gitlab-runner

    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c '${_register_cmds}'
    | EOT

  systemd::unit_file { "${service_name}-register.service":
    content => $_register_service,
    require => File[$config_path],
  }

  service { $service_name:
    ensure    => running,
    enable    => true,
    subscribe => Systemd::Unit_file["${service_name}-register.service"],
    require   => Systemd::Unit_file["${service_name}.service"],
  }
}
