function package::remove (
  Variant[String, Array[String]] $packages,
  $parameters = 'absent',
) {
  package::install($packages, $parameters)
}
