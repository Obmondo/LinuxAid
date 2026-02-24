# @summary Class for monitoring security exporter package update checks
#
# @param enable Boolean flag to enable or disable monitoring. Defaults to true.
#
# @groups enable enable
#
class monitor::system::service::security_exporter (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::package_update_failed":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
