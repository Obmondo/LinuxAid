# @summary Manages ThinLinc license files
#
# Syncs license files from a source directory to the ThinLinc licenses
# directory and restarts the vsmserver service when files change.
#
# @param license_source_path
#   Absolute path to the directory containing ThinLinc license files (files
#   starting with 'user'). All files are synced to /opt/thinlinc/etc/licenses
#   and vsmserver is restarted when any file content changes.
class thinlinc::license (
  Stdlib::Absolutepath $license_source_path = $thinlinc::license_source_path,
) inherits ::thinlinc {

  $license_dir = "${thinlinc::install_dir}/etc/licenses"

  file { $license_dir:
    recurse => true,
    source  => $license_source_path,
  }

  exec { 'vsmserver-restart-on-license-change':
    command     => 'systemctl restart vsmserver',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    subscribe   => File[$license_dir],
  }
}
