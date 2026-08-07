# @summary Class for managing backup configurations
#
# @param manage Whether to manage the backup setup. Defaults to true.
#
# @param enable Whether to enable the backup. Defaults to false.
#
# @param backup_user The user account used for backups. Defaults to 'obmondo-backup'.
#
# @param dump_dir The directory for dumps. Defaults to undef.
#
# @param lvm Whether to enable LVM. Defaults to undef.
#
# @param conf_dir The configuration directory path. Defaults to $common::__conf_dir.
#
# @groups management manage, enable, backup_user, conf_dir
#
# @groups storage dump_dir
#
# @groups lvm lvm
#
class common::backup (
  Boolean                        $manage      = true,
  Boolean                        $enable      = false,
  Eit_types::User                $backup_user = 'obmondo-backup',
  Optional[Stdlib::Absolutepath] $dump_dir    = undef,
  Optional[Boolean]              $lvm         = undef,
  Stdlib::Absolutepath           $conf_dir    = $common::__conf_dir,
) {
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
