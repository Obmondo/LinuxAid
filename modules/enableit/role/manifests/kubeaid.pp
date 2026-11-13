
# @summary KubeAid node role: loads common with every subsystem off by default (see
# common/data/role/role::kubeaid.yaml), so a cluster switches on only what it needs.
#
class role::kubeaid inherits ::role {

  include common::system

  # common only loads user management with monitoring on, which KubeAid nodes leave off;
  # authentication (e.g. sudo) is still switched on per cluster in hiera.
  include common::user_management::authentication

  # common::system skips its subclasses on KubeAid nodes; kernel is loaded here so a
  # cluster can set common::system::kernel::sysctl (e.g. inotify limits) in hiera.
  include common::system::kernel

  # Likewise for ZFS dataset properties (common::storage::zfs::datasets); ZFS itself is usually
  # installed by KubeAid StorageCTL, so common::storage::zfs::enable stays off by default.
  include common::storage::zfs

  # Likewise for automatic updates, so a cluster can remove unattended-upgrades
  # (common::system::updates::manage: true). Its 06:00 runs restart systemd-networkd, which can
  # leave a node's DHCP lease unrenewed until the address expires.
  include common::system::updates

  # Ubuntu -proposed pocket (eit_repos::apt::upstream::proposed and ::proposed_packages), for a fix
  # that is only in -proposed so far, e.g. a kernel security fix. common::system::repo is not loaded
  # on KubeAid nodes, so eit_repos is declared here, without purging the node's own sources and pins.
  # Set proposed to false (not just remove the key) to take the source and the pin off again.
  if lookup('eit_repos::apt::upstream::proposed', Optional[Boolean], undef, undef) =~ Boolean {
    class { 'eit_repos':
      upstream   => true,
      purge      => false,
      purge_pins => false,
    }
  }
}
