# @summary Enables/disables auditing at boot time.
#
# @param enable
#   Enable auditing in the kernel at boot time.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config::grub (
  Boolean $enable = true
) {
  if $enable {
    $_enable = '1'
  }
  else {
    $_enable = '0'
  }

  kernel_parameter { 'audit': value => $_enable }

  reboot_notify { 'audit': subscribe => Kernel_parameter['audit'] }
}
