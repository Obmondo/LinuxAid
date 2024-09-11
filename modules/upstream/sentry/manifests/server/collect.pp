# == Class: sentry::server:collect
#
# === Parameters
#
#  [*env*]
#    Value passed to tag, restricts where sentry server resources get collected
#
# === Actions:
#
#  Collects Sentry Project Resources add to 
#  the Sentry server
#
# === Authors:
#
#  Dan Sajner <dsajner@covermymeds.com>
#  Bil Schwanitz <bschwanitz@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class sentry::server::collect (
  $env = undef,
) {

  # Collect all the Sentry Projects
  ::Sentry::Source::Project <<| tag == $env |>>

}
