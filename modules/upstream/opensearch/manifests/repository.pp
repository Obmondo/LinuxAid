# @summary
#   Handle opensearch repository.
#
# @api private
#
class opensearch::repository {
  assert_private()

  case $facts['os']['family'] {
    'RedHat': {
      contain opensearch::repository::redhat
    }
    'Debian': {
      contain opensearch::repository::debian
    }
    default: {
      fail("Your OS ${facts['os']['family']} (${facts['os']['name']}) is not supported to use a repository for installing opensearch!")
    }
  }
}
