# == Class uwsgi::install
#
# This class is called from uwsgi for install.
#
class uwsgi::install {

  if $::uwsgi::setup_python {
    class{'::python':
      version    => 'system',
      pip        => 'present',
      dev        => 'present',
      virtualenv => 'present',
    }
    package { $uwsgi::package_name:
      ensure   => $uwsgi::package_ensure,
      provider => $uwsgi::package_provider,
      require  => Class['python'],
    }
  } else {
    package { $uwsgi::package_name:
      ensure   => $uwsgi::package_ensure,
      provider => $uwsgi::package_provider,
    }
  }

  user {$::uwsgi::user:
    ensure     => present,
    managehome => false,
    shell      => '/bin/false',
  }
}
