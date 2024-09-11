# Cron class
class common::cron (
  Variant[Boolean, Enum['root-only']] $purge_unmanaged = false,
  Hash                                $jobs            = {},
) {

  include ::profile::cron
}
