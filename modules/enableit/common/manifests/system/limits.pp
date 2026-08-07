# @summary Class for managing system limits
#
# @param manage Whether to manage the limits. Defaults to false.
#
# @param ulimits The ulimits configuration. Defaults to an empty hash.
#
# @groups management manage.
#
# @groups configuration ulimits.
#
class common::system::limits (
  Boolean                    $manage  = false,
  Eit_types::System::Ulimits $ulimits = {},
) {
  confine($manage,
    !lookup('common::user_management::authentication::manage_pam', Boolean, undef, false),
    'limits currently has a dependency on the PAM module'
  )
  include profile::system::limits
}
