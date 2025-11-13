# Syncoid
class sanoid::syncoid (
  Sanoid::Syncoid::Options $default_options,
) {

  systemd::manage_unit{'syncoid-replication@.service':
    ensure        => 'present',
    enable        => true,
    active        => true,
    unit_entry    => {
      'Description' => 'Syncoid Replication Service',
      'Wants'       => 'syncoid-replication-%i.timer',
    },
    service_entry => {
      'Type'            => 'oneshot',
      'ExecStart'       => "syncoid ${OPTIONS}",
      'EnvironmentFile' => '-/etc/default/sanoid-replication-%i',
    },
  }
}

