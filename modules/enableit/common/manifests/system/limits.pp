# Limits
class common::system::limits (
  Boolean                    $manage  = false,
  Boolean                    $purge   = false,
  Eit_types::System::Ulimits $ulimits = {},
) {

  confine($manage,
          !$common::system::authentication::manage_pam,
          'limits currently has a dependency on the PAM module')

  include profile::system::limits

}
