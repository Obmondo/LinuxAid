# Sanoid Service
class sanoid::service (
  Boolean $ensure = $sanoid::ensure_service,
) {

  service {
    [
      'sanoid.timer',
      'sanoid-prune.service'
    ]:
    ensure  => stdlib::ensure($ensure, 'service'),
    require => Package[$sanoid::package_name]
  }
}
