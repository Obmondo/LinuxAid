function monitor::package (
  Variant[String, Array[String]] $name,
  Variant[Boolean, String]       $install         = true,
  Hash                           $optional_params = {},
  Eit_types::Noop_Value          $noop_value      = lookup('monitor::noop_value'),
) {

  package::install($name, {
    ensure => $install ? {
      Boolean => ensure_latest($install),
      default => $install,
    },
    noop   => $noop_value,
  } + $optional_params)
}
