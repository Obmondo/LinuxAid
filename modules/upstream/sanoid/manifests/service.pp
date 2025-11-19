# Sanoid Service
class sanoid::service (
  Stdlib::Ensure::Service $ensure = $sanoid::ensure_service,
) {

  service {
    [
      'sanoid.timer',
      'sanoid-prune.service'
    ]:
    ensure  => $ensure,
    require => Package[$sanoid::package_name]
  }
}
