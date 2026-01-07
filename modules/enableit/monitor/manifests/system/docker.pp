# @summary Class for Docker monitoring
#
# @param enable Enable or disable Docker monitoring. Defaults to true.
#
# @groups enable enable
#
class monitor::system::docker (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::status":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
