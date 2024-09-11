# Read The Docs
class profile::projectmanagement::readthedocs (
  Eit_types::URL          $upstream_git_repo  = $::role::projectmanagement::readthedocs::upstream_git_repo,
  Eit_types::SimpleString $revision           = $::role::projectmanagement::readthedocs::revision,
  Eit_types::Host         $bind               = $::role::projectmanagement::readthedocs::bind,
  Stdlib::Port            $port               = $::role::projectmanagement::readthedocs::port,
  String                  $ssl_combined_pem   = $::role::projectmanagement::readthedocs::ssl_combined_pem,
  Boolean                 $manage_haproxy     = $::role::projectmanagement::readthedocs::manage_haproxy,
  Stdlib::Fqdn            $public_domainname  = $::role::projectmanagement::readthedocs::public_domainname,

) inherits ::profile {

  $_os_packages = [
    'git',
    'python-pip',
    'libxml2-devel',
    'libxslt-devel',
  ]

  $_user = 'readthedocs'
  $_user_home = '/var/lib/readthedocs'
  $_repo_dir = "${_user_home}/repo"
  $_virtualenv_dir = "${_user_home}/virtualenv"

  package::install($_os_packages)

  contain profile::redis

  user { $_user:
    ensure => present,
    home   => $_user_home,
  }

  file { $_user_home:
    ensure => directory,
    owner  => $_user,
  }

  vcsrepo { 'rtd repo':
    ensure   => present,
    name     => $_repo_dir,
    provider => 'git',
    source   => $upstream_git_repo,
    user     => $_user,
    revision => $revision,
    force    => true,
    require  => [
      Package['git'],
      File[$_user_home],
    ],
    notify   => Service['readthedocs.service'],
  }

  class { 'python' :
    version => 'system',
    pip     => 'latest',
  }

  python::pyvenv { 'readthedocs' :
    ensure     => present,
    version    => '36',
    systempkgs => true,
    venv_dir   => $_virtualenv_dir,
    owner      => 'root',
    require    => [
      Class['python'],
      Vcsrepo['rtd repo'],
    ]
  }

  file { "${_repo_dir}/readthedocs/templates/sphinx/conf.py":
    ensure  => file,
    source  => 'puppet:///modules/profile/projectmanagement/readthedocs/sphinx.conf.py',
    require => Vcsrepo['rtd repo'],
    notify  => Service['readthedocs.service'],
  }

  # FIXME: This doesn't really work?
  python::requirements { 'readthedocs':
    requirements => "${_repo_dir}/requirements.txt",
    virtualenv   => $_virtualenv_dir,
    pip_provider => 'pip3',
    owner        => $_user,
  }

  file { '/usr/local/bin/with_virtualenv.sh':
    ensure => 'file',
    mode   => 'a+x',
    source => 'puppet:///modules/profile/with_virtualenv.sh',
  }

  $_build_database = "${_user_home}/.build_database"
  exec { 'readthedocs: build database':
    command => "/usr/local/bin/with_virtualenv.sh ${_virtualenv_dir} 'python manage.py migrate' && touch ${_build_database}",
    cwd     => $_repo_dir,
    creates => $_build_database,
    require => [
      File['/usr/local/bin/with_virtualenv.sh'],
      Python::Requirements['readthedocs'],
    ],
    before  => Service['readthedocs.service'],
  }

  $_create_superuser = "${_user_home}/.create_superuser"
  exec { 'readthedocs: create superuser':
    command => "/usr/local/bin/with_virtualenv.sh ${_virtualenv_dir} 'python manage.py createsuperuser' && touch ${_create_superuser}",
    cwd     => $_repo_dir,
    creates => $_create_superuser,
    require => [
      File['/usr/local/bin/with_virtualenv.sh'],
      Python::Requirements['readthedocs'],
    ],
    before  => Service['readthedocs.service'],
  }

  $_collect_static = "${_user_home}/.collect_static"
  exec { 'readthedocs: generate static assets':
    command => "/usr/local/bin/with_virtualenv.sh ${_virtualenv_dir} 'python manage.py createsuperuser' && touch ${_collect_static}",
    cwd     => $_repo_dir,
    creates => $_collect_static,
    require => [
      File['/usr/local/bin/with_virtualenv.sh'],
      Python::Requirements['readthedocs'],
    ],
    before  => Service['readthedocs.service'],
  }

  $_load_data = "${_user_home}/.load_data"
  exec { 'readthedocs: load data and test project':
    command => "/usr/local/bin/with_virtualenv.sh ${_virtualenv_dir} 'python manage.py loaddata test_data' && touch ${_load_data}",
    cwd     => $_repo_dir,
    creates => $_load_data,
    require => [
      File['/usr/local/bin/with_virtualenv.sh'],
      Python::Requirements['readthedocs'],
    ],
    before  => Service['readthedocs.service'],
  }

  common::services::systemd { 'readthedocs.service':
    unit    => {
      'Description' => 'Read The Docs server',
      'Requires'    => 'network.target',
      'After'       => 'network.target',
    },
    service => {
      'EnvironmentFile'  => '-/etc/default/readthedocs',
      'WorkingDirectory' => $_repo_dir,
      'ExecStart'        => "/usr/local/bin/with_virtualenv.sh ${_virtualenv_dir} 'python manage.py runserver ${bind}:${port}'",
      'Restart'          => 'always',
      'RestartSec'       => '30s',
    },
    install => {
      'WantedBy' => 'multi-user.target',
    },
  }

  file {
    '/etc/ssl/private/readthedocs':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0500',
      ;

    '/etc/ssl/private/readthedocs/combined.pem':
      ensure  => file,
      content => $ssl_combined_pem,
      mode    => '0400',
      before  => Class['haproxy'],
      notify  => Service['haproxy'],
      require => File['/etc/ssl/private/readthedocs'],
      ;
  }

  if $manage_haproxy {
    class { '::eit_haproxy::auto_config' :
      encryption_ciphers => 'strict',
      redirect_http      => true,
      proxies            => {
        readthedocs_http => {
          letsencrypt   => false,
          mode          => 'http',
          binds         => {
            https_0_0_0_0_80  => {
              'ports'     => [80],
              'ssl'       => false,
              'ipaddress' => '0.0.0.0',
            },
            https_0_0_0_0_443 => {
              'ports'     => [443],
              'ssl'       => true,
              'options'   => 'crt /etc/ssl/private/readthedocs/combined.pem',
              'ipaddress' => '0.0.0.0',
            },
          },
          sites         => {
            readthedocs_http => {
                servers         => [
                  "127.0.0.1:${port}",
                ],
                default_backend => true,
            },
          },
          extra_options => {
            option => ['forwardfor'],
          }
        }
      },
    }
  }
}
