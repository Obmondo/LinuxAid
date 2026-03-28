# @summary Manages OpenVAS docker-compose resources.
#
# @param install
#   Whether to install and run the OpenVAS stack.
#
# @param compose_dir
#   Directory where compose artifacts are stored.
#
# @param feed_release
#   Greenbone feed release used by feed-related services.
#
# @param manage_docker
#   Whether Docker/Compose is managed by this module.
#
# @param admin_password
#   Password for the admin user. Passed to the gvmd service.
#
class openvas::compose (
  Boolean              $install        = $openvas::install,
  Stdlib::Absolutepath $compose_dir    = $openvas::compose_dir,
  String[1]            $feed_release   = $openvas::feed_release,
  Boolean              $manage_docker  = $openvas::manage_docker,
  String[1]            $admin_password = $openvas::admin_password,
) {
  $compose_file = "${compose_dir}/docker-compose.yml"

  $compose_require = $manage_docker ? {
    true    => [File[$compose_file], Class['docker::compose']],
    default => File[$compose_file],
  }

  file { $compose_dir:
    ensure => stdlib::ensure($install, 'directory'),
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $compose_file:
    ensure  => stdlib::ensure($install, 'file'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('openvas/docker-compose.yaml.epp', {
        'feed_release'   => $feed_release,
        'admin_password' => $admin_password,
    }),
    require => File[$compose_dir],
  }

  docker_compose { 'openvas':
    ensure        => stdlib::ensure($install),
    compose_files => [$compose_file],
    require       => $compose_require,
    subscribe     => File[$compose_file],
  }
}
