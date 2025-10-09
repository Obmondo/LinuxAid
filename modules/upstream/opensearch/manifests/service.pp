# @summary
#   Handle opensearch service.
#
# @api private
#
class opensearch::service {
  assert_private()

  if $opensearch::manage_service {
    if $opensearch::package_source == 'archive' {
      systemd::unit_file { 'opensearch.service':
        ensure  => 'present',
        content => epp('opensearch/opensearch.service.epp'),
        notify  => Service['opensearch'],
      }
    }

    service { 'opensearch':
      ensure => $opensearch::service_ensure,
      enable => $opensearch::service_enable,
    }
  }
}
