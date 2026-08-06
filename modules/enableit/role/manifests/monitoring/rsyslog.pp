
# @summary Class for managing the Rsyslog server role
#
# @param $__blendable
# Boolean indicating if the configuration is blendable. No default.
#
class role::monitoring::rsyslog (
  Boolean $__blendable,
) {

  include profile::collector::rsyslog
}
