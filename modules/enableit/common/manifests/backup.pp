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
# @param luks Whether to enable LUKS encryption. Defaults to undef.
#
# @param lukspass The LUKS passphrase. Defaults to undef.
#
# @param luks_service_name The service name that manages LUKS. Defaults to undef.
#
# @param lvm Whether to enable LVM. Defaults to undef.
#
# @param lvm_vg The LVM volume group name. Defaults to undef.
#
# @param lvm_extents_min_required The minimum required LVM extents percentage. Defaults to 15.
#
# @param conf_dir The configuration directory path. Defaults to $common::__conf_dir.
#
# @groups management manage, enable, backup_user, conf_dir
#
# @groups storage dump_dir
#
# @groups encryption luks, lukspass, luks_service_name
#
# @groups lvm lvm, lvm_vg, lvm_extents_min_required
#
class common::backup (
  Boolean                        $manage                   = true,
  Boolean                        $enable                   = false,
  Eit_types::User                $backup_user              = 'obmondo-backup',
  Optional[Stdlib::Absolutepath] $dump_dir                 = undef,
  Optional[Boolean]              $luks                     = undef,
  Optional[String]               $lukspass                 = undef,
  Optional[String]               $luks_service_name        = undef,
  Optional[Boolean]              $lvm                      = undef,
  Optional[String]               $lvm_vg                   = undef,
  Stdlib::Absolutepath           $conf_dir                 = $common::__conf_dir,
  Eit_types::Percentage          $lvm_extents_min_required = 15,
) {
  confine($lvm, !$lvm_vg, 'A LVM volume group must be set if `lvm` is enabled')
  confine($luks, !($lukspass or $luks_service_name),
    'A LUKS passphrase or the name of the service that starts LUKS must be defined if `luks` is enabled')
  confine($luks, $lukspass, $luks_service_name, 'Only one of `lukspass` and `luks_service_name` may be set')

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
