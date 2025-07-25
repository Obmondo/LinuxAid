# @summary Manage packages based on Hash input
#
# This has been created as a Defined Type so that it can be properly referenced
# in manifest ordering
#
# @param packages
#   Hash of the packages to install
#
#   * If just a key is provided, will apply `package_ensure` to the item
#   * A value may be provided to the package name key that will be passed along
#     as the arguments for resource creation.
#   * A special entry called `defaults` can be provided that will set the
#     default package options for all packages in the `Hash`
#
#   @example Adding a package to be installed
#     simplib::install({ 'my_package' => undef })
#
# @param defaults
#   A `Hash` of default parameters to apply to all `$packages`
#
#   * This will be overridden by any options applied to individual packages
#
#   @example Adding some packages with defaults
#     simplib::install(
#       # The package list
#       {
#         'pkg1' => {
#           'ensure' => 'installed'
#         },
#         'pkg2' => undef
#       },
#       # The defaults
#       {
#         'ensure'      => 'latest',
#         'configfiles' => 'replace'
#       }
#     )
#
define simplib::install (
  Hash[String[1], Optional[Hash]] $packages,
  Hash[String[1], String[1]]      $defaults  = { 'ensure' => 'present' }
){
  $packages.each |String $package, Optional[Hash] $opts| {
    if $opts =~ Hash {
      $_opts = merge($defaults, $opts)
    }
    else {
      $_opts = $defaults
    }

    ensure_packages($package, $_opts)
  }
}
