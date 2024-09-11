# == Class: gerrit::service
#
# This class manages the Gerrit service itself
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::service {

  $service_enabled = $gerrit::service_enabled

  unless is_bool($service_enabled) {
    validate_re($service_enabled, '^manual$',
      "${service_enabled} is not supported for service_enabled. \
Allowed values are true, false, 'manual'.")
  }

  if (is_bool($service_enabled)) {
    # $gerrit::service_enabled maps directly to ensure
    $ensure = $service_enabled
  }
  else {
    # $gerrit::service_enabled maps only to enable, set ensure to undef
    $ensure = undef
  }

  $enable = $service_enabled

  service { 'gerrit':
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
  }
}
