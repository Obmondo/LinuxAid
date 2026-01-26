# manifests/xmlstarlet.pp

class subversion::xmlstarlet {
  include ::subversion

  package{'xmlstarlet':
    ensure => present,
  }
}
