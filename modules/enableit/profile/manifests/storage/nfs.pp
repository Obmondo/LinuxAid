# Storage NFS profile
class profile::storage::nfs (
  Boolean $enable            = $common::storage::nfs::enable,
  Boolean $unmount_snapshots = $common::storage::nfs::unmount_snapshots,
) {

  class { 'nfs::client': }

  # Determine if node has any currently mounted NFS mounts
  #
  # Get mountpoints fact
  $_has_nfs_mounts = $facts.dig('mountpoints').then |$_mountpoints| {
    # Extract `filesystem` value for each mountpoint
    $_mountpoints.map |$_mountpoint, $_mountpoint_options| {
      $_mountpoint_options.dig('filesystem')
    }.then |$_mountpoint_filesystems| {
      # Check if `nfs` or `nfs4` is in the list of filesystems
      'nfs' in $_mountpoint_filesystems or 'nfs4' in $_mountpoint_filesystems
    }
  }

  # Automatically lazy unmount mounted snapshots from NetApp
  profile::cron::job { 'umount netapp snapshots':
    enable      => $_has_nfs_mounts,
    command     => 'findmnt -t nfs,nfs4 -o TARGET --raw | grep /.snapshot/ | xargs --no-run-if-empty umount -l',
    hour        => 2,
    minute      => 5,
    environment => {
      'PATH' => '/bin:/usr/bin',
    }
  }
}
