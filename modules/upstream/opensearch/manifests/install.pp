# @summary
#   Installs opensearch via archive, package, or repository.
#
# @api private
#
class opensearch::install {
  assert_private()

  if $opensearch::manage_package {
    if $opensearch::package_source == 'archive' {
      contain opensearch::install::archive
    } else {
      contain opensearch::install::package
    }
  }
}
