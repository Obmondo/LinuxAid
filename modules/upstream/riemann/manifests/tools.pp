# == Class: riemann::tools
#
# A module to manage the riemann tools provided by the tools gem,
# includes services for net and health at present
#
# === Parameters
#
# [*health_enabled*]
#   Whether to start the riemann health daemon to collect system stats
#   defaults to true
#
# [*net_enabled*]
#   Whether to start the riemann health daemon to collect system stats
#   defaults to true
#
# [*health_user*]
#   The system user which riemann-health runs as. Defaults to riemann-health.
#   Will be created by the module.
#
# [*net_user*]
#   The system user which riemann-net runs as. Defaults to riemann-net.
#   Will be created by the module.
#
# [*rvm_ruby_string*]
#   The RVM Ruby version which should be used. Defaults to undef.
#
class riemann::tools (
  Boolean $enable = false,
  Boolean $health_enabled,
  String $health_user,
  Boolean $net_enabled,
) {

  package { ['riemann-tools']:
    provider => gem,
  }

  class { 'riemann::tools::service': } ->
  Class['riemann::tools']
}
