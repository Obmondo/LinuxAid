# Run puppet on client nodes
class profile::puppet::run_puppet (
  Eit_types::Certname $certname = $::trusted['certname']
) {

  Service {
    noop => false,
  }

  File {
    noop => false,
  }

  package { 'obmondo-run-puppet':
    ensure => latest,
    noop   => false,
  }

  file { '/etc/default/run_puppet':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    content => anything_to_ini({
      'PUPPETCERT'    => $::facts['hostcert'],
      'PUPPETPRIVKEY' => $::facts['hostprivkey'],
    }),
    require => Package['obmondo-run-puppet'],
  }

  if $facts['init_system'] != 'systemd' {
    [$_minute, $_hour] = [fqdn_rand(60), '*']

    cron { 'run-puppet':
      ensure      => present,
      command     => '/opt/obmondo/bin/run_puppet >/dev/null',
      environment => [
        'MAILTO=ops@obmondo.com',
        "PUPPETCERT=${::facts['hostcert']}",
        "PUPPETPRIVKEY=${::facts['hostprivkey']}",
      ],
      user        => 'root',
      minute      => $_minute,
      hour        => $_hour,
      noop        => false,
      require     => Package['obmondo-run-puppet'],
    }
  } else {

    # Change the upgrade service timer timing.
    $_minutes = fqdn_rand(300, $facts['networking']['hostname'])

    $_timer = @("EOT"/$n)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Requires=run-puppet.service
      Description=Run puppet agent based on the noop status

      [Install]
      WantedBy=timers.target

      [Timer]
      OnBootSec=15m
      OnUnitActiveSec=1h
      Unit=run-puppet.service
      RandomizedDelaySec=${_minutes}s
      | EOT

    $_service = @("EOT"/$n)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Run puppet agent based on the noop status
      Wants=run-puppet.timer

      [Service]
      Type=oneshot
      EnvironmentFile=-/etc/default/run_puppet
      Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin:/opt/obmondo/bin"
      ExecStart=/opt/obmondo/bin/run_puppet --certname ${certname}
      | EOT

    systemd::timer { 'run-puppet.timer':
      timer_content   => $_timer,
      service_content => $_service,
      active          => true,
      enable          => true,
      require         => Package['obmondo-run-puppet'],
    }
  }
}
