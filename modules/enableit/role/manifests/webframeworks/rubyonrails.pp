
#
# @summary Class for managing the RubyonRails role
#
# @param version The version of RubyonRails to install. Defaults to 5.
#
# @param provider The provider to use for installing RubyonRails. Defaults to 'package'.
#
# @groups ruby_version version.
#
# @groups installation provider.
#
class role::webframeworks::rubyonrails (
  Enum[4, 5] $version = 5,
  Enum['gem', 'package'] $provider = 'package',
) inherits ::role::webframeworks {

  class { '::role::db::mysql': }

  class { '::profile::appeng::passenger':
    http_server        => 'apache',
    passenger_version  => $version,
    passenger_provider => $provider,
    manage_web_server  => false,
  }
}
