
# @summary Class for managing the Foswiki project management role
#
# @param version The version of Foswiki to manage. No default.
#
# @groups service version
#
class role::projectmanagement::foswiki (
  Variant[Integer, String] $version,
) {
  include profile::projectmanagement::foswiki
  include role::virtualization::docker
}
