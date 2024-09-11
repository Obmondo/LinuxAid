# reexport insights client and make it access able via hirea
class common::software::insights(
  Boolean           $manage     = false,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) {

  if $manage {
    if $facts['os']['family'] ==  'RedHat'{
      contain profile::software::insights
    }
  }
}
