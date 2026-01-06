# @summary Class for managing system limits
#
# @param manage Whether to manage the limits. Defaults to false.
#
# @param purge Whether to purge existing limits. Defaults to false.
#
# @param ulimits The ulimits configuration. Defaults to an empty hash.
#
# @groups management manage, purge.
#
# @groups configuration ulimits.
#
class common::system::limits (
  Boolean                    $manage  = false,
  Boolean                    $purge   = false,
  Eit_types::System::Ulimits $ulimits = {},
) {
  confine($manage,
    !$common::system::authentication::manage_pam,
    'limits currently has a dependency on the PAM module'
  )
  include profile::system::limits
}
