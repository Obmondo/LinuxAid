# Run openvox-agent on client nodes
class profile::openvox::run_openvox (
  Eit_types::Noop_Value $noop_value = $common::openvox::noop_value,
) {

  package { 'obmondo-run-puppet':
    ensure => absent,
    noop   => $noop_value,
  }

  file { '/etc/default/run_puppet':
    ensure => absent,
  }

  if $facts['init_system'] == 'systemd' {
    Service {
      noop => $noop_value,
    }

    File {
      noop => $noop_value,
    }

    # Change the upgrade service timer timing.
    $_minutes = fqdn_rand(300, $facts['networking']['hostname'])

    $_timer = @("EOT"/$n)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Requires=run-openvox.service
      Description=Run Openvox Agent based on the noop status

      [Install]
      WantedBy=timers.target

      [Timer]
      OnBootSec=1m
      OnUnitActiveSec=1h
      Unit=run-openvox.service
      RandomizedDelaySec=${_minutes}s
      | EOT

    $_service = @(EOT)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Run Openvox Agent based on the noop status
      Wants=run-openvox.timer

      [Service]
      Type=oneshot
      EnvironmentFile=-/etc/default/linuxaid-cli
      Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin:/opt/obmondo/bin"
      ExecStart=/opt/obmondo/bin/linuxaid-cli run-openvox
      | EOT

    systemd::timer { 'run-puppet.timer':
      ensure => absent,
    }

    systemd::timer { 'run-openvox.timer':
      ensure          => present,
      timer_content   => $_timer,
      service_content => $_service,
      active          => true,
      enable          => true,
      require         => Archive['linuxaid-cli'],
    }
  }
}
