# Cloudamize
class common::software::cloudamize (
  Boolean           $manage       = false,
  Boolean           $enable       = false,
  Optional[String]  $customer_key = undef,
  Optional[Boolean] $noop_value   = undef,
) inherits common {

  confine($enable, !$customer_key,
          '`$customer_key` must be provided')

  if $manage {
    contain profile::software::cloudamize
  }
}
