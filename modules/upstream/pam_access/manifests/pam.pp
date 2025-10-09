# Class: pam_access::pam
#
# Private class - Not to be used directly
# See README.md for usage information
#
# [Remember: No empty lines between comments and class definition]
class pam_access::pam {

  case $::osfamily {
    'RedHat': {
      anchor { 'pam_access::pam::begin': } -> class { 'pam_access::pam::redhat': } -> anchor { 'pam_access::pam::end': }
    }
    'Debian': {
      anchor { 'pam_access::pam::begin': } -> class { 'pam_access::pam::debian': } -> anchor { 'pam_access::pam::end': }
    }
    default: {}
  }

}
