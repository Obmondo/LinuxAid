class riemann::install (
  String $package_name,
  Variant[Enum['latest'], String] $version,
) {
  include java

  package { $package_name:
    ensure => $version,
  }

}
