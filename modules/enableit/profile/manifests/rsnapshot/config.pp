# RsnapShot config
class profile::rsnapshot::config inherits ::rsnapshot::config { #lint:ignore:inherits_across_namespaces

  # Make sure the rsnapshot lock dir is always created. Under systemd `/var/run`
  # is a symlink to `/run` which is a tmpfs, so after a reboot we need to create
  # the directory.
  File[$::rsnapshot::lockpath] {
    noop => false,
    mode => 'u+w',
  }

}
