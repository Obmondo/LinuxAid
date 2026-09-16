# @summary Manages ThinLinc license files
#
# Syncs license files from a source directory to the ThinLinc licenses
# directory and restarts the vsmserver service when files change.
#
# @param license_source_path
#   Absolute path to the directory containing ThinLinc license files (files
#   starting with 'user'). All files are synced to /opt/thinlinc/etc/licenses
#   and vsmserver is restarted when any file content changes. The directory is
#   purged, so anything not present in the source directory is removed: point
#   this at a directory holding the licenses of exactly one subscription.
class thinlinc::license (
  Stdlib::Absolutepath $license_source_path = $thinlinc::license_source_path,
) inherits ::thinlinc {

  $license_dir = "${thinlinc::install_dir}/etc/licenses"

  # Licenses from different subscriptions cannot be combined in a cluster as
  # of ThinLinc 4.21, so licenses that are no longer in the source directory
  # have to be removed rather than left behind.
  file { $license_dir:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    force   => true,
    source  => $license_source_path,
  }

  exec { 'vsmserver-restart-on-license-change':
    command     => 'systemctl restart vsmserver',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    subscribe   => File[$license_dir],
  }
}
