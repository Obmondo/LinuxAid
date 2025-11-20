# Eit_Repos define
define eit_repos::repo (
  Boolean               $ensure     = true,
  Optional[
    Variant[
      String,
      Array
    ]
  ]                     $versions   = undef,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $_package_provider = lookup('eit_repos::package_provider', String, undef, $facts['package_provider'])
  $os_name = $facts['os']['name']

  $_options = if $versions != undef {
    {
      versions => $versions,
    }
  }

  $_defaults = {
    ensure     => $ensure,
    noop_value => $noop_value,
  }

  # Note: Skip repo setup for TurrisOS, for now.
  if $os_name != 'TurrisOS' {
    class { "eit_repos::${_package_provider}::${name}":
      * => stdlib::merge($_options, $_defaults),
    }
  }
}
