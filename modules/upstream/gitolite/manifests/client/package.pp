# Class: gitolite::client::package
#
# Description
#  This class is designed to install Git client packages
#
# Parameters:
#  This class takes no parameters
#
# Actions:
#   This class installs git client binaries via Packages.
#
# Requires:
#   This module has no requirements
#
# Sample Usage:
#   This method should not be called directly.
class gitolite::client::package {
  package { $gitolite::params::gt_client_package:
    ensure => 'present',
  }
}
