# Syncoid
class sanoid::syncoid (
  Sanoid::Syncoid::Options $default_options,
  Array[String]                 $allow_sync_from = $sanoid::allow_sync_from,
  Sanoid::Syncoid::Replications $replications    = $sanoid::replications,
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

  $allow_sync_from.each |$pub_key| {
    $syncoid_pubkey_parts = split($pub_key, ' ')

    ssh_authorized_key { "syncoid ssh key from ${syncoid_pubkey_parts[2]}":
      ensure  => present,
      user    => 'root',
      type    => $syncoid_pubkey_parts[0],
      key     => $syncoid_pubkey_parts[1],
      options => [
        # TODO: wrapper script to limit the access
        # 'command="/usr/sbin/syncoid"',
        'no-port-forwarding',
        'no-X11-forwarding',
        'no-agent-forwarding',
        'no-pty',
      ],
    }
  }

  $replications.each |String $pool_name, Sanoid::Syncoid::Replication $options| {
    sanoid::syncoid::job { $pool_name:
      * => $options,
    }
  }
}
