# == Class: curator::install
#
# Handles the package installation
#
class curator::install {
  if ($curator::manage_repo == true) {
    # Set up repositories
    include ::curator::repo
  }

  package { $curator::package_name:
    ensure   => $curator::ensure,
    provider => $curator::package_provider,
  }
}
