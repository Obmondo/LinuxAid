# Syncoid
class sanoid::syncoid (
  Sanoid::Syncoid::Options $default_options,
) {

  include systemd

  # Create the template service unit (only once)
  systemd::unit_file { 'syncoid-replication@.service':
    content => epp('sanoid/syncoid-replication@.service.epp'),
  }

  # Ensure config directory exists
  file { '/etc/syncoid':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
