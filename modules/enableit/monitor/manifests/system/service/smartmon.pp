# @summary Class for managing the Smartmon Checks
#
# @param enable Boolean flag to enable or disable Smartmon checks. Defaults to false.
#
class monitor::system::service::smartmon (
  Boolean $enable = false,
) inherits monitor::system::service {
  @@monitor::alert { "${title}::disk_healthy":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
