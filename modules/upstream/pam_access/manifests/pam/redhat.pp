# Class: pam_access::pam::redhat
#
# Private class - Not to be used directly
# See README.md for usage information
#
# [Remember: No empty lines between comments and class definition]
class pam_access::pam::redhat {

  $authconfig_flags = $pam_access::ensure ? {
    'present' => join($pam_access::enable_pamaccess_flags, ' '),
    'absent'  => join($pam_access::disable_pamaccess_flags, ' '),
  }
  $authconfig_update_cmd = "/usr/sbin/authconfig ${authconfig_flags} --update"
  $authconfig_test_cmd   = "/usr/sbin/authconfig ${authconfig_flags} --test"
  $authconfig_check_cmd  = "/usr/bin/test \"`${authconfig_test_cmd}`\" = \"`/usr/sbin/authconfig --test`\""

  exec { 'authconfig-access':
    command => $authconfig_update_cmd,
    unless  => $authconfig_check_cmd,
  }

}
