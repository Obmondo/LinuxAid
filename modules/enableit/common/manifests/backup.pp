# @summary Class for managing backup configurations
#
# @param manage Whether to manage the backup setup. Defaults to true.
#
# @param install_client Whether to install the backup client. Defaults to false.
#
# @param enable Whether to enable the backup. Defaults to false.
#
# @param backup_user The user account used for backups. Defaults to 'obmondo-backup'.
#
# @param dump_dir The directory for dumps. Defaults to undef.
#
# @param backup_user_password The password for the backup user. Defaults to undef.
#
# @param keep_days Number of days to keep backups. Defaults to 30.
#
# @param backup_window_starthour The start hour for backup window (0-23). Defaults to undef.
#
# @param backup_window_lasthour The end hour for backup window (0-23). Defaults to undef.
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
# @param push A hash for push configurations. Defaults to empty hash.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @param root_password The root password for secure operations. Defaults to undef.
#
# @groups management manage, install_client, enable, backup_user, backup_user_password, encrypt_params
#
# @groups storage dump_dir, keep_days, backup_window_starthour, backup_window_lasthour
#
# @groups encryption luks, lukspass, luks_service_name
#
# @groups lvm lvm, lvm_vg, lvm_extents_min_required
#
# @groups push_config push
#
# @groups security root_password
#
# @encrypt_params backup_user_password, root_password
#
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
  Optional[Eit_types::Password]  $root_password            = undef,
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
  Eit_types::Encrypt::Params     $encrypt_params            = ['backup_user_password', 'root_password'],

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
