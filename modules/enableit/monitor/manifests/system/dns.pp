# @summary Class for monitoring DNS resolution
#
# @param enable Boolean flag to enable or disable DNS monitoring. Defaults to true.
#
# @groups enable enable
#
class monitor::system::dns (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::resolution":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
