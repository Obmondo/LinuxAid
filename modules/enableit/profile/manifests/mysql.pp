# Mysql Profile
class profile::mysql (
  Stdlib::Absolutepath                  $datadir                        = '/var/lib/mysql',
  Optional[Eit_types::Password]         $root_password                  = undef,
  Array[Stdlib::IP::Address]            $access_mysql_from              = ['0.0.0.0/0'],
  Eit_types::Percentage                 $innodb_buffer_percentage       = 75,
  Boolean                               $mysql_restart_on_config_change = false,
  Boolean                               $backup                         = true,
  Stdlib::Port                          $mysql_port                     = 3306,
  String                                $mysql_monitor_username         = 'obmondo-mon',
  String                                $mysql_monitor_password         = 'M0n1t0rE2',
  String                                $mysql_monitor_hostname         = 'localhost',
  Boolean                               $binlog                         = true,
  Enum['MIXED', 'ROW', 'STATEMENT']     $binlog_format                  = 'MIXED',
  Boolean                               $local_tcp_root_access          = false,
  Optional[Stdlib::Absolutepath]        $binlog_dir                     = "${datadir}/binlog/${facts['networking']['fqdn']}",
  Optional[Integer[4096, 1073741824]]   $binlog_max_size_bytes          = 1*1024*1024*1024, # 1 GB
  Optional[Integer[0, 4294967295]]      $binlog_sync                    = 1,
  Hash[Eit_types::Mysql_Variable, Data] $override_options               = {},
  Eit_types::Version                    $package_ensure                 = 'installed',
) {

  # Monitoring
  contain ::common::monitor::exporter::mysql

  # Backup
  if $backup {
    contain common::backup::db::mysql
  }

  firewall_multi { '000 allow mysql connections':
    proto  => 'tcp',
    dport  => $mysql_port,
    jump   => 'accept',
    source => $access_mysql_from,
  }

  if $facts['os']['selinux']['enabled'] {
    selinux::fcontext { 'selinux-fcontext-mysql-datadir':
      pathspec => $datadir,
      seltype  => 'mysqld_db_t',
    }
  }

  # Set cache to approx 70-80% of total mem - should be calculated from
  # actual physical mem !

  # FIXME: We need to make sure this works. According to docs
  # (https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size),
  # this value may grow beyond what we set it to:
  #
  #   "Buffer pool size must always be equal to or a multiple of
  #   innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances. If you alter
  #   the buffer pool size to a value that is not equal to or a multiple of
  #   innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances, buffer pool
  #   size is automatically adjusted to a value that is equal to or a multiple
  #   of innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances that is
  #   not less than the specified buffer pool size. "
  #
  # This means that we should make sure the value we arrive at is not greater
  # that the maximum available memory; this would happen in a case where chunk
  # size is high.
  #
  # We use `max` to ensure that we never get below a pool size of 512 MB; if it
  # gets too low mysql wastes CPU cycles.
  $innodb_buffer_pool_size = max(512, Integer(functions::memory_human_readable('MB') * ($innodb_buffer_percentage/100)))

  # Default for every OS's
  $mysql_defaults = {
    'bind_address'              => '0.0.0.0',
    'datadir'                   => $datadir,
    'key_buffer_size'           => '16M',
    'log_bin'                   => $binlog_dir,
    # log wrong logins etc.
    'log_warnings'              => 2,
    'max_allowed_packet'        => '16M',
    'max_connections'           => 1024,
    'max_heap_table_size'       => '256M',
    'myisam_recover'            => 'BACKUP',
    'query_cache_limit'         => '1M',
    'query_cache_size'          => '32M',
    'relay_log_space_limit'     => '2GB',
    'skip-name-resolve'         => true,
    'table_open_cache'          => '1024',
    # autosize if -1: `8 + max_connections/100` ~ 18 if 1024 max connections
    'thread_cache_size '        => -1,
    'thread_stack'              => '256K',
    'tmp_table_size'            => '256M',

    'binlog_format'             => $binlog_format,
    'max_binlog_size'           => $binlog_max_size_bytes,
    'sync_binlog'               => $binlog_sync,

    'innodb_buffer_pool_size'   => "${innodb_buffer_pool_size}M",
    'innodb_file_per_table'     => true,
    'innodb_flush_method'       => 'O_DIRECT',
    'innodb_thread_concurrency' => '0',
    # necessary when using innodb_file_per_table
    'innodb_open_files'         => '1024',
    # let innodb engines find optimal concurrency
    'innodb_read_io_threads'    => $facts['processors']['count'] * 2,
    # set to max because innodb_thread_concurrency=0 should mean it scales
    # automaticly.
    'innodb_write_io_threads'   => $facts['processors']['count'] * 2,
  }

  if $facts['os']['release']['major'] == '16.04' {
    $package_server_name = 'mariadb-server'
    $package_client_name = 'mariadb-client'
  } else {
    $package_server_name = undef
    $package_client_name = undef
  }

  # Mysql class
  class { '::mysql::server':
    package_ensure   => $package_ensure,
    package_name     => $package_server_name,
    root_password    => $root_password,
    restart          => $mysql_restart_on_config_change,
    override_options => {
      'mysqld' => $mysql_defaults + $override_options,
    },
  }

  if $local_tcp_root_access {
    mysql_user { 'root@127.0.0.1':
      ensure        => present,
      password_hash => mysql_password($root_password),
      require       => Class['mysql::server::service'],
    }
  }

  # Create/Check mon user only if we are able to login as root
  if $facts['mysql_rootuser'] {
    mysql_user { "${mysql_monitor_username}@${mysql_monitor_hostname}":
      ensure        => present,
      password_hash => mysql_password($mysql_monitor_password),
      require       => Class['mysql::server::service'],
    }

    mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}/*.*":
      ensure     => present,
      user       => "${mysql_monitor_username}@${mysql_monitor_hostname}",
      table      => '*.*',
      privileges => [ 'SELECT', 'PROCESS', 'REPLICATION CLIENT' ],
      require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
    }
  }

  class { '::mysql::client' :
    package_name => $package_client_name,
  }

  # If we use systemd we can let it handle mounting any encrypted disks before
  # mysqld starts
  if $facts['service_provider'] == 'systemd' {
    $service_d = "/etc/systemd/system/${::mysql::server::service_name}.service.d"

    file { $service_d:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }

    ini_setting {
      default:
        ensure            => present,
        path              => "${service_d}/override.conf",
        section           => 'Service',
        key_val_separator => '=',
        notify            => Exec['daemon-reload'],
        require           => File[$service_d],
        before            => Class['::mysql::server'];

      'mysql_service_require_mount':
        section => 'Unit',
        setting => 'RequiresMountsFor',
        value   => $datadir;
    }
  }

  file { "/var/log/${mysql::server::service_name}":
    ensure => directory,
    before => Service['mysqld'],
  }
}
