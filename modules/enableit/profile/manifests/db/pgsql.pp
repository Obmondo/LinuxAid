# Profile postgresql
class profile::db::pgsql (
  Eit_types::SimpleString            $monitor_username,
  Eit_types::Password                $monitor_password,
  Eit_types::Pgsql::Db               $databases            = $role::db::pgsql::databases,
  Eit_types::Pgsql::Mode             $mode                 = $role::db::pgsql::mode,
  Integer[0, default]                $max_connections      = $role::db::pgsql::max_connections,
  Array[Stdlib::IP::Address]         $listen_address       = $role::db::pgsql::listen_address,
  Array[Stdlib::IP::Address]         $allow_remote_hosts   = $role::db::pgsql::allow_remote_hosts,
  Optional[Eit_types::SimpleString]  $recovery_username    = $role::db::pgsql::recovery_username,
  Optional[String]                   $recovery_password    = $role::db::pgsql::recovery_password,
  Optional[Eit_types::Host]          $recovery_host        = $role::db::pgsql::recovery_host,
  Optional[Stdlib::Port]             $recovery_port        = $role::db::pgsql::recovery_port,
  Optional[Stdlib::Unixpath]         $recovery_trigger     = $role::db::pgsql::recovery_trigger,
  Optional[Eit_types::SimpleString]  $replication_username = $role::db::pgsql::replication_username,
  Optional[String]                   $replication_password = $role::db::pgsql::replication_password,
  Optional[Eit_types::SimpleString]  $application_name     = $role::db::pgsql::application_name,
  Optional[Eit_types::Pgsql::Pg_hba] $pg_hba_rule          = $role::db::pgsql::pg_hba_rule,
) {

  # Backup
  contain ::common::backup::db::pgsql

  $allow_remote_hosts.each |$host| {
    # Firewall
    firewall_multi { "000 allow pgsql connections from ${host}":
      proto       => 'tcp',
      dport       => 5432,
      destination => $listen_address,
      source      => $host,
      jump        => 'accept',
    }

    postgresql::server::pg_hba_rule { "allow outside TCP access from ${host}":
      type        => 'host',
      user        => 'all',
      database    => 'all',
      address     => $host,
      auth_method => 'md5',
    }
  }

  $_listen_address = $listen_address.map |$addr| {
    cidr_split($addr)[0]
  }.join(', ')

  $_logdir = '/var/log/postgresql'

  # Remove the custom logrotate
  logrotate::rule { 'postgresql':
    ensure => 'absent',
  }

  # Manage the logrotate rule
  logrotate::rule { 'postgresql-common':
    ensure        => 'present',
    path          => "${_logdir}/*.log",
    rotate_every  => 'daily',
    rotate        => 30,
    missingok     => true,
    copytruncate  => true,
    ifempty       => false,
    compress      => true,
    delaycompress => true,
    su            => true,
    su_user       => 'root',
    su_group      => 'root',
  }

  # Setup Server
  class { 'postgresql::server':
    listen_addresses     => $_listen_address,
    encoding             => 'UTF-8',
    locale               => 'en_US.UTF-8',
    manage_recovery_conf => if $mode == 'standby' { true },
    logdir               => $_logdir,
    manage_logdir        => true,
  }

  postgresql::server::config_entry {
    'max_connections':
      value => $max_connections,
      ;
    'log_filename':
      value => 'postgresql.log',
      ;

    'client_min_messages':
      value => 'notice',
      ;
    'log_min_messages':
      value => 'warning',
      ;
    'log_min_error_statement':
      value => 'error',
      ;
    'log_min_duration_statement':
      value => 2000,
      ;
    'log_checkpoints':
      value => 'on',
      ;
    'log_connections':
      value => 'on',
      ;
    'log_disconnections':
      value => 'on',
      ;
    'log_duration':
      value => 'off',
      ;
    'log_error_verbosity':
      value => 'default',
      ;
    'log_hostname':
      value => 'on',
      ;
    'log_lock_waits':
      value => 'on'
      ;
  }

  # Setup pg_hba rule as required by customers
  $pg_hba_rule.each |$key, $options| {
    $options['user'].each |$user| {
      postgresql::server::pg_hba_rule { "allow application network to access ${options['database']} database from ${key} for ${user}":
        description => "Open up PostgreSQL for access for ${user} from ${options['address']}",
        type        => pick($options['type'], 'host'),
        database    => $options['database'],
        user        => $user,
        address     => $options['address'],
        auth_method => pick($options['auth_method'], 'md5')
      }
    }
  }

  # Setup pg_hba rule for monitoring global# Currently allow from all the host
  postgresql::server::pg_hba_rule { "allow ${monitor_username} to access all databases from everywhere":
    description => "Open up PostgreSQL for access for ${monitor_username} from everywhere",
    type        => 'host',
    database    => 'postgres',
    user        => $monitor_username,
    address     => '0.0.0.0/0',
    auth_method => 'md5',
  }

  if $mode == 'standby' {
    postgresql::server::config_entry { 'hot_standby':
      value => 'on',
    }

    postgresql::server::config_entry { 'synchronous_standby_names':
      value => undef,
    }

    postgresql::server::recovery { 'hot_standby_recovery.conf':
      standby_mode     => 'on',
      trigger_file     => $recovery_trigger,
      primary_conninfo => "host=${recovery_host} port=${recovery_port} user=${recovery_username} password=(${recovery_password}.node_encrypt::secret) application_name=${application_name}", #lint:ignore:140chars
    }
  }

  # NOTE: This is partial setup, since we first need to setup the pg_basebackup from replica to get the replica working
  if $mode == 'primary' {
    # Replication Settings
    postgresql::server::config_entry {
      'max_wal_senders':
        value => 1,
        ;
      'wal_level':
        value => 'hot_standby',
        ;
      'wal_keep_segments':
        value => 32,
        ;
    }

    # Replication User
    postgresql::server::role { $replication_username :
      ensure        => 'present',
      superuser     => false,
      inherit       => false,
      replication   => true,
      username      => $replication_username,
      password_hash => postgresql::postgresql_password($replication_username, ($replication_password.node_encrypt::secret)),
    }
  }

  unless $mode == 'standby' {
    # The monitor user needs to be a superuser, as per
    # https://dba.stackexchange.com/questions/58271/how-to-view-the-query-of-another-session-in-pg-stat-activity-without-being-super
    postgresql::server::role { $monitor_username :
      superuser     => true,
      password_hash => postgresql::postgresql_password($monitor_username, $monitor_password),
      require       => Class['postgresql::server'],
    }

    $databases.each |$db_name, $db_options| {
      postgresql::server::db { $db_name:
        user     => $db_options['user'],
        password => $db_options['password'],
        grant    => $db_options['grant'],
      }
    }
  }
}
