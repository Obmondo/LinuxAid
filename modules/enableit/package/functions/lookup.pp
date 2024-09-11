# Lookup all packages and return a hash of our representation => real package
# name
function package::lookup (
  Array[Pattern[/\A[[:graph:]]+\Z/]] $packages = [],
) {
  $packages.reduce({}) |$acc, $p| {
    # Package name without any trailing modifiers
    $_real_package_name = regsubst($p, '^(.*?)[-+]?$', '\1', 'E')

    # The trailing char is a modifier to allow us to negate the default
    # operation; installing a package named `asd-` will actually remove it,
    # while removing `asd+` will install it.
    $_trailing_char = regsubst($p, '.*?([-+]?)$', '\1', 'E')

    # Lookup the package name, defaulting to the the unmodified name if not
    # found.
    $_found_package_name = lookup("package::${_real_package_name}", String, undef, $_real_package_name)

    # We return an array of the real package name and parameters. The parameters
    # are used only when the package name has a trailing char ('+' or '-') as
    # this should result in the opposite action
    $_parameters = $_trailing_char ? {
      '+'     => {
        ensure => 'present',
      },
      '-'     => {
        ensure => 'absent',
      },
      ''      => {},
      default => fail("Got unknown trailing char '${_trailing_char}"),
    }

    merge($acc, {
      $p => [$_found_package_name, $_parameters]
    })
  }
}
