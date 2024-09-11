# profile::puppet::clientbucket for puppet clientbucket cache cleanup
class profile::puppet::clientbucket {

  Service {
    noop => false,
  }

  File {
    noop => false,
  }

  $_timer = @("EOT"/$n)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Requires=cleanup_puppet.service
    Description=cleanup pupet cache file every morning

    [Install]
    WantedBy=timers.target

    [Timer]
    OnCalendar=*-*-* 0:0:0
    Unit=cleanup_puppet.service
    | EOT

  $_service = @(EOT)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Cleanup Puppet cache
    Wants=cleanup_puppet.timer

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/find /opt/puppetlabs/puppet/cache/clientbucket -type f -mtime +30 -delete
    | EOT

  # delete puppet cache everyday if it is older than 30 days
  systemd::timer { 'cleanup_puppet.timer':
    timer_content   => $_timer,
    service_content => $_service,
    active          => true,
    enable          => true,
  }
}
