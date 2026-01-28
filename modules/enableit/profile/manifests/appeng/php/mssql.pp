# Microsoft MS SQL
class profile::php::mssql (
  Boolean $ensure = $::profile::php::mssql,
) {

  # Setup the repo
  apt::source { 'mssql-release':
    ensure       => ensure_present($ensure),
    location     => 'https://packages.microsoft.com/ubuntu/16.04/prod',
    architecture => 'amd64',
    release      => $facts['os']['distro']['codename'],
    repos        => 'main',
    key          => {
      'id'     => 'BC528686B50D79E339D3721CEB3E94ADBE1229CF',
      'source' => 'https://packages.microsoft.com/keys/microsoft.asc',
    },
    include      => {
      'src' => false,
    },
  }

  contain ::php::dev

  # Set the module
  [ 'sqlsrv', 'pdo_sqlsrv' ].each |$mod| {
    php::extension { $mod:
      provider => 'pecl',
    }
  }

  # Some requirements
  # https://www.microsoft.com/en-us/sql-server/developer-get-started/php/ubuntu/
  package::install([
    'unixodbc',
    'unixodbc-dev',
  ])

  # TODO: Do we have a better way to handle this
  # https://stackoverflow.com/questions/43984594/automate-installation-of-msodbcsql-with-puppet
  exec { '/usr/bin/apt-get -yq install msodbcsql':
    environment => 'ACCEPT_EULA=Y',
    unless      => '/usr/bin/dpkg -l msodbcsql | tail -1 | grep ^ii',
  }
}
