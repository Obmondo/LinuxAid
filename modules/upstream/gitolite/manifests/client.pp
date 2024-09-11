# Class: gitolite::client
#
# This module manages git client management
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly.
class gitolite::client {
  include stdlib

  anchor { 'gitolite::client::begin': }
  -> class { 'gitolite::client::package': }
  -> anchor { 'gitolite::client::end': }
}
