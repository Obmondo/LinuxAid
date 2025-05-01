# Class: razor
# ===========================
#
# Full description of class razor here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'razor':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class razor (
  Boolean $manage_postgres,
  Optional[Eit_types::Host] $db_server,
  Eit_types::SimpleString $db_name,
  Eit_types::SimpleString $db_user,
  Eit_types::Password $db_password,
  Array[Stdlib::AbsolutePath] $additional_brokers = [],
  Array[Stdlib::AbsolutePath] $additional_hooks = [],
  Array[Stdlib::AbsolutePath] $additional_tasks = [],
) {

  if $facts['init_system'] != 'systemd' {
    fail('Only systemd systems provided')
  }

  if !$manage_postgres and !$db_server {
    fail('$db_server must be given if not managing $manage_postgres is `true`')
  }

  package {
    default:
      ensure => 'present',
      ;
    'razor-server':
      ;
    'ruby':
      ;
    'razor-client':
      provider => 'gem',
      require  => Package['ruby'],
      ;
  }

  if $manage_postgres {
    class { 'postgresql::globals':
      manage_package_repo => true,
      version             => '9.2',
    }

    class { 'postgresql::server':
      require => Class['postgresql::globals'],
    }

    postgresql::server::db { $db_name:
      user     => $db_user,
      password => postgresql_password($db_user, $db_password),
      require  => Class['postgresql::server'],
    }
  }

  service { 'razor-server':
    ensure  => true,
    enable  => true,
    require => Package['razor-server'],
  }

  $_db_user_escaped = uriescape($db_user)
  $_db_password_escaped = uriescape($db_password)

  file { '/etc/puppetlabs/razor-server/config.yaml':
    ensure  => 'file',
    content => stdlib::to_yaml({
      'production' => {
        'database_url' => "jdbc:postgresql://${db_server}/${db_name}?user=${_db_user_escaped}&password=${_db_password_escaped}",
      },
      'all'        => {
        'auth'                 => {
          'enabled'         => false,
          'config'          => 'shiro.ini',
          'allow_localhost' => false,
        },
        'microkernel'          => {
          'debug_level' => 'debug',
          'kernel_args' => undef,
        },
        'secure_api'           => false,
        'protect_new_nodes'    => false,
        'store_hook_input'     => false,
        'store_hook_output'    => false,
        'match_nodes_on'       => [
          'mac',
        ],
        'checkin_interval'     => 15,
        'repo_store_root'      => '/opt/puppetlabs/server/data/razor-server/repo',
        'broker_path'          => ($additional_brokers + [
          'brokers',
        ]).join(':'),
        'hook_path'            => ($additional_hooks + [
          'hooks',
        ]).join(':'),
        'task_path'            => ($additional_tasks + [
          'tasks',
        ]).join(':'),
        'hook_execution_path'  => undef,
        'facts'                => {
          'blacklist' => [
            'domain',
            'filesystems',
            'fqdn',
            'hostname',
            'id',
            '/kernel.*/',
            'memoryfree',
            'memorysize',
            'memorytotal',
            '/operatingsystem.*/',
            'osfamily',
            'path',
            'ps',
            'rubysitedir',
            'rubyversion',
            'selinux',
            'sshdsakey',
            '/sshfp_[dr]sa/',
            'sshrsakey',
            '/swap.*/',
            'timezone',
            '/uptime.*/',
          ],
          # Facts that should be used to match nodes on; these are useful if the
          # primary hardware information like MAC addresses has changed (e.g.,
          # because of a motherboard replacement), but you want to make sure
          # that an existing node is still identified as the 'old' node. These
          # facts must be unique across all nodes that Razor manages -
          # otherwise, it will erroneously identify two physically different
          # nodes as the same.
          #
          # The entries in the array follow the same format as those for
          # facts.blacklist
          'match_on'  => undef,

          # These should correspond to config properties that should be hidden
          # from the /api/collections/config endpoint. By default, this endpoint
          # will reveal all config in this file.
        },
        'api_config_blacklist' => [
          'database_url',
          'facts.blacklist',
        ]
      },
    }),
    notify  => Service['razor-server'],
  }


}
