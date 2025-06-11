# An optional class that will allow a suitable repository to be configured
# from which packages for Apache Cassandra can be downloaded.
# @param descr [string] On the Red Hat family, this is passed as the `descr`
#   attribute to a `yumrepo` resource.  On the Debian family, it is passed as
#   the `comment` attribute to an `apt::source` resource.
# @param key_id [string] On the Debian family, this is passed as the `id`
#   attribute to an `apt::key` resource.  On the Red Hat family, it is
#   ignored.
# @param key_url [string] On the Debian family, this is passed as the
#   `source` attribute to an `apt::key` resource.  On the Red Hat family,
#   it is set to the `gpgkey` attribute on the `yumrepo` resource.
# @param pkg_url [string] On the Red Hat family, leaving this as default will
#   set the `baseurl` on the `yumrepo` resource to
#   'http://www.apache.org/dist/cassandra/redhat' with whatever is set in the
#   'release' attribute appended.
#   On the Debian family, leaving this as the default
#   will set the `location` attribute on an `apt::source` to
#   'http://www.apache.org/dist/cassandra/debian'.
# @param release [string] On the Debian family, this is passed as the `release`
#   attribute to an `apt::source` resource.  On the Red Hat family, it is the
#   major version number of Cassandra, without dot, and with an appended 'x'
#   (e.g. '311x')
class cassandra::apache_repo (
  $descr   = 'Repo for Apache Cassandra',
  $key_id  = 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
  $key_url = 'https://www.apache.org/dist/cassandra/KEYS',
  $pkg_url = undef,
  $release = 'main',
) {
  case $facts['os']['family'] {
    'RedHat': {
      if $pkg_url != undef {
        $baseurl = $pkg_url
      } else {
        $url = 'http://www.apache.org/dist/cassandra/redhat'
        $baseurl = "${url}/${release}"
      }

      yumrepo { 'cassandra_apache':
        ensure   => present,
        descr    => $descr,
        baseurl  => $baseurl,
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => $key_url,
      }
    }
    'Debian': {
      include apt
      include apt::update

      apt::key { 'apache.cassandra':
        id     => $key_id,
        source => $key_url,
        before => Apt::Source['cassandra.sources'],
      }

      if $pkg_url != undef {
        $location = $pkg_url
      } else {
        $location = 'http://www.apache.org/dist/cassandra/debian'
      }

      apt::source { 'cassandra.sources':
        location => $location,
        comment  => $descr,
        release  => $release,
        include  => {
          'src' => false,
        },
        notify   => Exec['update-apache-cassandra-repo'],
      }

      # Required to wrap apt_update
      exec { 'update-apache-cassandra-repo':
        refreshonly => true,
        command     => '/bin/true',
        require     => Exec['apt_update'],
      }
    }
    default: {
      warning("OS family ${facts['os']['family']} not supported")
    }
  }
}
