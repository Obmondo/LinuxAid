# Class: gitolite::server::package
#
# Description
#  This class is designed to install Git server packages
#
# Parameters:
#  This class takes no parameters
#
# Actions:
#   This class installs git/gitweb server binaries via Packages.
#
# Requires:
#   This module has no requirements.
#
# Sample Usage:
#   This method should not be called directly.
class gitolite::server::package {
  package { $gitolite::params::gt_server_package:
    ensure => 'present',
  }
}
