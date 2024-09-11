# Installs basic ZFS kernel and userland support.
#
# @example Declaring the class
#   include zfs
#
# @example Tuning the ZFS ARC
#   class { 'zfs':
#     zfs_arc_max => to_bytes('256 M'),
#     zfs_arc_min => to_bytes('128 M'),
#   }
#
# @param conf_dir Top-level configuration directory, usually `/etc/zfs`.
# @param kmod_type Whether to use DKMS kernel packages or ones built to match
#   the running kernel (only applies to RHEL platforms).
# @param manage_repo Whether to setup and manage external package repositories.
# @param package_name The name of the top-level metapackage that installs ZFS
#   support.
# @param service_manage Whether to manage the various ZFS services.
# @param zfs_arc_max Maximum size of the ARC in bytes.
# @param zfs_arc_min Minimum size of the ARC in bytes.
#
# @see puppet_classes::zfs::zed zfs::zed
# @see puppet_defined_types::zfs::scrub zfs::scrub
class zfs (
  Stdlib::Absolutepath              $conf_dir,
  Enum['dkms', 'kabi']              $kmod_type,
  Boolean                           $manage_repo,
  Variant[String, Array[String, 1]] $package_name,
  Boolean                           $service_manage,
  Optional[Integer[0]]              $zfs_arc_max,
  Optional[Integer[0]]              $zfs_arc_min,
) {

  contain zfs::install
  contain zfs::config
  contain zfs::service

  Class['zfs::install'] ~> Class['zfs::config'] ~> Class['zfs::service']
}
