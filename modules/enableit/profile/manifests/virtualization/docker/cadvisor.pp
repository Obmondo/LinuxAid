# cadvisor docker container
class profile::virtualization::docker::cadvisor (
  Boolean               $enable         = $common::monitor::exporter::enable,
  Eit_types::Noop_Value $noop_value     = undef,
  Stdlib::Port          $listen_port    = 63392,
  String                $cadvisor_image = $role::virtualization::docker::cadvisor_image,
) inherits profile::virtualization::docker {

  Exec {
    noop => $noop_value,
  }
  File {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }

  # docker cadvisor setup
  #
  # using detach => false as systemd not able to start docker container properly
  # but exit status is 0 always
  docker::run { 'obmondo_monitoring_cadvisor':
    ensure           => ensure_present($enable),
    image            => $cadvisor_image,
    command          => '-docker_only',
    detach           => false,
    ports            => [ "127.254.254.254:${listen_port}:8080" ],
    expose           => [ '8080' ],
    volumes          => [ '/:/rootfs:ro',
                          '/var/lib/docker:/var/lib/docker:ro',
                          '/var/run:/var/run:ro',
                          '/sys:/sys:ro',
                          '/cgroup:/cgroup:ro' ],
    extra_parameters => [ '--restart=unless-stopped' ],
    require          => Class['docker'],
  }

}
