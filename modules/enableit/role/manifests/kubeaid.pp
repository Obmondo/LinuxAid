
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

  # common::system::repo is not loaded on KubeAid nodes either, so eit_repos (and with it the apt
  # class that apt::conf and apt::source need) is declared here, without purging the node's own
  # sources and pins. Upstream repos can be switched on in hiera (eit_repos::upstream).
  if $facts['os']['family'] == 'Debian' {
    class { 'eit_repos':
      purge      => false,
      purge_pins => false,
    }
  }

  # Likewise for automatic updates, so a cluster can remove unattended-upgrades
  # (common::system::updates::manage: true). Its 06:00 runs restart systemd-networkd, which can
  # leave a node's DHCP lease unrenewed until the address expires.
  include common::system::updates
}
