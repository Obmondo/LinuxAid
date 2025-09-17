# @summary Class for managing the Ansoft Remote Simulation Manager (RSM) Service
#
# This class installs and manages the Ansoft RSM systemd service,
# including setting up environment variables and configuring
# the service startup command.
#
# @param enable
#   Whether to enable and manage the service. Defaults to value from
#   `common::software::ansoftrsmservice::enable`.
#
# @param env
#   A hash of environment variables to set in `/etc/default/ansoftrsmservice`.
#   Defaults to value from `common::software::ansoftrsmservice::env`.
#
# @param ansysrsm_path
#   The base installation path of the Ansoft RSM software.
#   Used in both environment variables and ExecStart.
#   Defaults to value from `common::software::ansoftrsmservice::ansysrsm_path`.
# 
class profile::software::ansoftrsmservice (
  Boolean $enable        = $common::software::ansoftrsmservice::enable,
  Hash    $env           = $common::software::ansoftrsmservice::env,
  String  $ansysrsm_path = $common::software::ansoftrsmservice::ansysrsm_path,
) {

  file { '/etc/default/ansoftrsmservice':
    ensure  => ensure_present($enable),
    mode    => '0644',
    owner   => 'root',
    content => anything_to_ini($env),
  }

  $_service_content = @("EOT"/$n)
    # THIS FILE IS MANAGED BY LINUXAID. CHANGES WILL BE LOST.

    [Unit]
    Description=Ansoft Remote Simulation Manager Service
    After=syslog.target remote-fs.target
    Wants=network-online.target
    Conflicts=shutdown.target

    [Service]
    User=root
    Type=forking
    EnvironmentFile=-/etc/default/ansoftrsmservice
    ExecStart=${ansysrsm_path}/ansoftrsmservice.exe -log ${ansysrsm_path}/ansoftrsmservice.log -readonlycfg
    KillSignal=SIGINT
    LimitNOFILE=8192
    UMask=22
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::unit_file { 'ansoftrsmservice.service':
    ensure    => ensure_present($enable),
    enable    => $enable,
    active    => $enable,
    content   => $_service_content,
    require   => File['/etc/default/ansoftrsmservice'],
    subscribe => File['/etc/default/ansoftrsmservice'],
  }
}
