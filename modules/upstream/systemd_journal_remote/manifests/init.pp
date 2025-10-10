# @summary
#   This module manages and configures the systemd journal remote package
#
# @api public
#
# @param manage_package
#   Manage the `systemd-journal-remote` package installation
#
# @param package_name
#   The `systemd-journal-remote` package name to use
#
# @param package_ensure
#   The `systemd-journal-remote` package state
#
# @author Dan Gibbs <dev@dangibbs.co.uk>
#
class systemd_journal_remote (
  Boolean $manage_package                             = true,
  String $package_name                                = 'systemd-journal-remote',
  Enum['latest', 'absent', 'present'] $package_ensure = present,
) {
  if $manage_package {
    package { $package_name:
      ensure => $package_ensure,
    }
  }
}
