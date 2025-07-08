# @summary Class for SSacli Checks
#
# @param enable Boolean flag to enable or disable the SSacli checks. Defaults to false.
#
class monitor::system::service::ssacli (
  Boolean $enable = false,
) inherits monitor::system::service {
  @@monitor::alert { "${title}::disk_healthy":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
