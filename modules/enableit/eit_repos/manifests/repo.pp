# Eit_Repos define
define eit_repos::repo (
  Boolean           $ensure     = true,
  Boolean           $noop_value = $eit_repos::noop_value,
  Optional[
    Variant[
      String,
      Array
    ]
  ]                 $versions   = undef,
) {

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
