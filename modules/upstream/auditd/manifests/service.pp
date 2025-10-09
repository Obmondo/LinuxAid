# NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# @summary Ensure that the auditd service is running
#
# @param ensure
#   ``ensure`` state from the service resource
#
# @param enable
#   ``enable`` state from the service resource
#
# @param bypass_kernel_check
#   Do not check to see if the kernel is enforcing auditing before trying to
#   manage the service.
#
#   * This may be required if auditing is not being actively managed in the
#     kernel and someone has stopped the auditd service by hand.
#
# @param warn_if_reboot_required
#   Add a ``reboot_notify`` warning if the system requires a reboot before the
#   service can be managed.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::service (
  Variant[String[1],Boolean] $ensure                  = pick(getvar('auditd::enable'), 'running'),
  Boolean                    $enable                  = pick(getvar('auditd::enable'), true),
  Boolean                    $bypass_kernel_check     = false,
  Boolean                    $warn_if_reboot_required = true
){
  assert_private()

  if $bypass_kernel_check or $facts.dig('simplib__auditd', 'kernel_enforcing') {
    # CCE-27058-7
    service { $auditd::service_name:
      ensure  => $ensure,
      enable  => $enable,
      start   => "/sbin/service ${auditd::service_name} start",
      stop    => "/sbin/service ${auditd::service_name} stop",
      restart => "/sbin/service ${auditd::service_name} restart"
    }
  }
  elsif $warn_if_reboot_required {
    reboot_notify { "${auditd::service_name} service":
      reason =>  "The ${auditd::service_name} service cannot be started when the kernel is not enforcing auditing"
    }
  }
}
