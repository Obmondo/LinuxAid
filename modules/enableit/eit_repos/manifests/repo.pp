# Eit_Repos define
define eit_repos::repo (
  Boolean           $ensure     = true,
  Optional[
    Variant[
      String,
      Array
    ]
  ]                 $versions   = undef,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  # We most likely don't want $noop_value to be `true` (because that causes noop
  # to be forced); we most likely intend to use `undef` instead.
  if $noop_value {
    notify { '$noop_value is true!': }
  }

  $_package_provider = if $facts['package_provider'] == 'dnf' {
    'yum'
  } else {
    $facts['package_provider']
  }

  $_options = if $versions != undef {
    {
      versions => $versions,
    }
  }

  $_defaults = {
    ensure     => $ensure,
    noop_value => $noop_value,
  }

  class { "eit_repos::${_package_provider}::${name}":
    * => stdlib::merge($_options, $_defaults),
  }
}
