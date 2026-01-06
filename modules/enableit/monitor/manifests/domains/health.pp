# @summary Class for monitoring domain health
#
# @param enable Enable or disable domain health monitoring. Defaults to true.
#
# @groups settings enable
#
class monitor::domains::health (
  Boolean $enable = true,
) {
  @@monitor::alert { 'monitor::domains::cert_expiry':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { 'monitor::domains::status':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
