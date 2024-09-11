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
  $ensure                  = present,
  $manage_pam              = true,
  $enable_pamaccess_flags  = $pam_access::params::enable_pamaccess_flags,
  $disable_pamaccess_flags = $pam_access::params::disable_pamaccess_flags,
  $entries                 = {},
) inherits pam_access::params {

  validate_re($ensure, ['\Aabsent|present\Z'])
  validate_bool($manage_pam)
  validate_array($enable_pamaccess_flags, $disable_pamaccess_flags)
  validate_hash($entries)

  file { '/etc/security/access.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $manage_pam {
    anchor { 'pam_access::begin': } ->
    class { '::pam_access::pam':
      require => File['/etc/security/access.conf'],
    } ->
    anchor { 'pam_access::end': }
  }

  create_resources('pam_access::entry', $entries)

}
