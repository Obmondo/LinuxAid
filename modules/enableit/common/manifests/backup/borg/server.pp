# @summary Class for managing the Borg Backup Server (The Target Node) where backup will be saved.
#
# @param backup_root The root directory for backups. Defaults to the value of $::common::backup::dump_dir.
#
# @param authorized_keys Hash of authorized SSH keys with associated user keys.
#
# @groups backup_parameters backup_root, authorized_keys.
#
define common::backup::borg::server (
  Stdlib::Absolutepath $backup_root     = $::common::backup::dump_dir,
  Hash                 $authorized_keys = $::common::backup::borg::authorized_keys,
) {
  $authorized_keys.each |$key, $value| {
    $_backup_root = "${backup_root}/${key}"
    $_ssh_pub_key = $value['keys']
    ssh_authorized_key { "obmondo borg ssh backup pubkey for ${key}":
      ensure  => present,
      user    => $::common::backup::backup_user,
      key     => $_ssh_pub_key,
      type    => 'ssh-rsa',
      options => [
        "command=\"borg serve --restrict-to-path ${_backup_root}\"",
        'no-pty',
        'no-agent-forwarding',
        'no-port-forwarding',
        'no-X11-forwarding',
        'no-user-rc',
      ],
    }
  }
}
