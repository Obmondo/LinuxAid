# Foswiki
class role::projectmanagement::foswiki (
  Variant[Integer, String] $version,
  Boolean                  $manage_haproxy = true,
) {

  include profile::projectmanagement::foswiki
  include role::virtualization::docker
}
