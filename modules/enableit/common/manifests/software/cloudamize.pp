# @summary Class for managing Cloudamize software
#
# @param manage Whether to manage the Cloudamize software. Defaults to false.
#
# @param enable Whether to enable the Cloudamize software. Defaults to false.
#
# @param customer_key Optional customer key for Cloudamize.
#
# @param noop_value Optional parameter for noop mode.
#
# @groups management_params manage, enable
#
# @groups optional_params customer_key, noop_value
#
class common::software::cloudamize (
  Boolean               $manage       = false,
  Boolean               $enable       = false,
  Optional[String]      $customer_key = undef,
  Eit_types::Noop_Value $noop_value   = undef,
) inherits common {

  confine($enable, !$customer_key,
          '`$customer_key` must be provided')

  if $manage {
    contain profile::software::cloudamize
  }
}
