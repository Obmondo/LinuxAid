# An optional class that will allow a suitable repository to be configured
# from which packages for DataStax Community can be downloaded.  Changing
# the defaults will allow any Debian Apt or Red Hat Yum repository to be
# configured.
# @param descr [string] On the Red Hat family, this is passed as the `descr`
#   attribute to a `yumrepo` resource.  On the Debian family, it is passed as
#   the `comment` attribute to an `apt::source` resource.
# @param key_id [string] On the Debian family, this is passed as the `id`
#   attribute to an `apt::key` resource.  On the Red Hat family, it is
#   ignored.
# @param key_url [string] On the Debian family, this is passed as the
#   `source` attribute to an `apt::key` resource.  On the Red Hat family,
#   it is ignored.
# @param pkg_url [string] If left as the default, this will set the `baseurl`
#   to 'http://rpm.datastax.com/community' on a `yumrepo` resource
#   on the Red Hat family.  On the Debian family, leaving this as the default
#   will set the `location` attribute on an `apt::source` to
#   'http://debian.datastax.com/community'.
# @param release [string] On the Debian family, this is passed as the `release`
#   attribute to an `apt::source` resource.  On the Red Hat family, it is
#   ignored.
class cassandra::datastax_repo (
  $descr   = 'DataStax Repo for Apache Cassandra',
  $key_id  = '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
  $key_url = 'http://debian.datastax.com/debian/repo_key',
  $pkg_url = undef,
  $release = 'stable',
) {
  case $facts['os']['family'] {
    'RedHat': {
      if $pkg_url != undef {
        $baseurl = $pkg_url
      } else {
        $baseurl = 'http://rpm.datastax.com/community'
      }

      yumrepo { 'datastax':
        ensure   => present,
        descr    => $descr,
        baseurl  => $baseurl,
        enabled  => 1,
        gpgcheck => 0,
      }
    }
    'Debian': {
      include apt
      include apt::update

      apt::key { 'datastaxkey':
        id     => $key_id,
        source => $key_url,
        before => Apt::Source['datastax'],
      }

      if $pkg_url != undef {
        $location = $pkg_url
      } else {
        $location = 'http://debian.datastax.com/community'
      }

      apt::source { 'datastax':
        location => $location,
        comment  => $descr,
        release  => $release,
        include  => {
          'src' => false,
        },
        notify   => Exec['update-cassandra-repos'],
      }

      # Required to wrap apt_update
      exec { 'update-cassandra-repos':
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
