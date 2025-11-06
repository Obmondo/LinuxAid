# =Class perforce::package
#
# ==Description
# Install the perforce packages
#
class perforce::package {

  package { $perforce::packages:
    ensure  => installed,
  }
}
