# @summary Class for Dell hardware SSD CLI checks
#
# @param enable Whether to enable the SSD checks. Defaults to false.
#
# @groups enable enable
#
class monitor::system::service::dellhw (
  Boolean $enable = false,
) inherits monitor::system::service {
  @@monitor::alert { "${title}::disk_healthy":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
