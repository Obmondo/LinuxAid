
# @summary Class for managing the Foswiki project management role
#
# @param version The version of Foswiki to manage. No default.
#
# @param manage_haproxy Whether to manage HAProxy for the service. Defaults to true.
#
# @groups service version, manage_haproxy
#
class role::projectmanagement::foswiki (
  Variant[Integer, String] $version,
  Boolean $manage_haproxy = true,
) {
  include profile::projectmanagement::foswiki
  include role::virtualization::docker
}
