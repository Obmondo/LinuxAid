# @summary Class for monitoring MD Raid
#
# @param enable Boolean flag to enable or disable monitoring. Defaults to true.
#
# @groups enable enable
#
class monitor::raid::mdraid (
  Boolean $enable = true,
) {
  ['degraded', 'failed'].each |$x| {
    @@monitor::alert { "${name}::${x}":
      enable => $enable,
      tag    => $::trusted['certname'],
    }
  }
}
