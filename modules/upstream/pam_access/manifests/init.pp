# Class: pam_access
#
# This module manages pam_access
#    this module manages /etc/security/access.conf file
#
# Parameters:
#
#   $exec: true, false
#
#   If true, pam_access will take care of calling authconfig to apply its
#   changes; if false, you must do this yourself elsewhere in your manifest.
#
# Actions:
#
# Requires:
#
# See pam_access::entry for more documentation.
#
# [Remember: No empty lines between comments and class definition]
class pam_access (
  Enum['present', 'absent'] $ensure = present,
  Boolean $manage_pam               = true,
  Array $enable_pamaccess_flags     = $pam_access::params::enable_pamaccess_flags,
  Array $disable_pamaccess_flags    = $pam_access::params::disable_pamaccess_flags,
  Hash $entries                     = {},
) inherits pam_access::params {

  file { '/etc/security/access.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $manage_pam {
    anchor { 'pam_access::begin': }
    -> class { 'pam_access::pam':
      require => File['/etc/security/access.conf'],
    }
    -> anchor { 'pam_access::end': }
  }

  create_resources('pam_access::entry', $entries)

}
