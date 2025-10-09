# =Class perforce::package
#
# ==Description
# Install the perforce packages
#
class perforce::package {
  $packages = ['helix-p4dctl', 'helix-proxy', 'helix-broker', 'helix-cli', 'helix-p4d' ]

  package { $packages:
    ensure  => installed,
  }
}