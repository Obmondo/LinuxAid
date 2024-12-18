# Backup Class
class common::backup (
  Boolean                        $manage                   = true,
  Boolean                        $install_client           = false,
  Boolean                        $enable                   = false,
  Eit_types::User                $backup_user              = 'obmondo-backup',
  Optional[Stdlib::Absolutepath] $dump_dir                 = undef,
  Optional[Eit_types::Password]  $backup_user_password     = undef,
  Optional[Integer]              $keep_days                = 30,
  Optional[Integer[0,23]]        $backup_window_starthour  = undef,
  Optional[Integer[0,23]]        $backup_window_lasthour   = undef,
  Optional[Boolean]              $luks                     = undef,
  Optional[String]               $lukspass                 = undef,
  Optional[String]               $luks_service_name        = undef,
  Optional[Boolean]              $lvm                      = undef,
  Optional[String]               $lvm_vg                   = undef,
  Eit_types::Percentage          $lvm_extents_min_required = 15,
  Hash[
    String,
    Struct[
      {
      target      => Eit_types::Host,
      source      => Stdlib::Absolutepath,
      destination => Stdlib::Absolutepath,
      keep_time   => Pattern[/[0-9]+[DMWY]/],
      hour        => Eit_types::TimeHour,
      email       => Optional[Eit_types::Email],
      exclude     => Array[Variant[Stdlib::Absolutepath,String]],
  }]]                            $push                     = {},
) {
  confine($lvm, !$lvm_vg, 'A LVM volume group must be set if `lvm` is enabled')

  confine($luks, !($lukspass or $luks_service_name),
    'A LUKS passphrase or the name of the service that starts LUKS must be defined if `luks` is enabled')
  confine($luks, $lukspass, $luks_service_name, 'Only one of `lukspass` and `luks_service_name` may be set')

  # TODO: this is not used anymore rdiff-backup.
  # remove it later
  unless empty($push) {
    create_resources('common::backup::push', $push)
  }

  if $manage {
    user { $backup_user:
      ensure         => present,
      comment        => 'Obmondo Backup User',
      forcelocal     => true,
      gid            => 'obmondo',
      system         => true,
      shell          => '/bin/bash',
      managehome     => true,
      home           => '/opt/obmondo/home/obmondo-backup',
      password       => '!',
      purge_ssh_keys => true,
      require        => Group['obmondo'],
    }

    # We only want to include borg if we actually use it
    unless lookup('common::backup::borg::repos', Hash, undef, {}).empty {
      common::backup::borg.contain
    }

    if lookup('common::backup::netbackup::enable', Boolean, undef, false) {
      common::backup::netbackup.contain
    }

    if lookup('common::backup::db::enable', Boolean, undef, false) {
      common::backup::db.contain
    }

    if lookup('common::backup::gitea::enable', Boolean, undef, false) {
      common::backup::gitea.contain
    }
  }
}
