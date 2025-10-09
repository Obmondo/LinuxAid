# == Class: rsnapshot
#
# default params
class rsnapshot::params {
  $hosts                         = undef
  $conf_d                        = '/etc/rsnapshot' # the place where the host specific configs are stored
  $config_backup_user            = 'root'
  $package_name                  = 'rsnapshot'
  $package_ensure                = 'present'
  $cron_service_name             = $::osfamily ? {
    'RedHat' => 'crond',
    'Debian' => 'cron',
    default  => '',
    }
  $manage_cron                   = true
  $cron_dir                      = '/etc/cron.d'
  $config_backup_levels          = [ 'daily', 'weekly', 'monthly' ]
  $config_backup_defaults        = true
  $config_version                = '1.2'
  $config_check_mk_job           = false
  $config_cmd_cp                 = '/bin/cp'
  $config_cmd_rm                 = '/bin/rm'
  $config_cmd_rsync              = '/usr/bin/rsync'
  $config_cmd_ssh                = '/usr/bin/ssh'
  $config_cmd_logger             = '/usr/bin/logger'
  $config_cmd_du                 = '/usr/bin/du'
  $config_cmd_rsnapshot_diff     = '/usr/bin/rsnapshot-diff'
  $config_cmd_preexec            = undef
  $config_cmd_postexec           = undef
  $config_cronfile_prefix        = 'rsnapshot_'
  $config_cronfile_prefix_use    = false
  $config_use_lvm                = undef
  $config_linux_lvm_cmd_lvcreate = undef # '/sbin/lvcreate'
  $config_linux_lvm_cmd_lvremove = undef # '/sbin/lvremove'
  $config_linux_lvm_cmd_mount    = undef # '/sbin/mount'
  $config_linux_lvm_cmd_umount   = undef # '/sbin/umount'
  $config_linux_lvm_snapshotsize = undef # '100M'
  $config_linux_lvm_snapshotname = undef # 'rsnapshot'
  $config_linux_lvm_vgpath       = undef # '/dev'
  $config_linux_lvm_mountpath    = undef # '/mount/rsnapshot'
  $config_logpath                = '/var/log/rsnapshot'
  $config_logfile                = '/var/log/rsnapshot.log'  # unused, we are logging to $logpath/$host.log
  $config_lockpath               = '/var/run/rsnapshot'
  $config_snapshot_root          = '/backup'
  $config_no_create_root         = undef # bool, true or false
  $config_verbose                = '2'
  $config_loglevel               = '4'
  $config_stop_on_stale_lockfile = undef # bool
  $config_rsync_short_args       = '-az'
  $config_rsync_long_args        = undef # defaults are --delete --numeric-ids --relative --delete-excluded
  $config_ssh_args               = undef
  $config_du_args                = undef
  $config_one_fs                 = undef
  $config_retain                 = { }
  $config_interval               = {
    'daily'   => '7',
    'weekly'  => '4',
    'monthly' => '6',
  }
  $config_include                = []
  $config_exclude                = []
  $config_include_file           = undef
  $config_exclude_file           = undef
  $config_link_dest              = false
  $config_sync_first             = false
  $config_rsync_numtries         = 1
  $config_use_lazy_deletes       = false
  $config_default_backup         = {
    '/etc'  => './',
    '/home' => './',
  }
  $config_backup_scripts         = {}
  $cron = {
    mailto     => 'admin@example.com',
    hourly     => {
      minute   => '0..59',
      hour     => '*',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '*',
    },
    daily      => {
      minute   => '0..59',
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '*',
    },
    weekly     => {
      minute   => '0..59',
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '0..6',
    },
    monthly    => {
      minute   => '0..59',
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '1..28',
      month    => '*',
      weekday  => '*',
    },
  }
  $backup_scripts = {
    mysql               => {
      dbbackup_user     => 'root',
      dbbackup_password => '',
      dumper            => 'mysqldump',
      dump_flags        => '--single-transaction --quick --routines --ignore-table=mysql.event',
      ignore_dbs        => [ 'information_schema', 'performance_schema' ],
      compress          => 'pbzip2',
    },
    psql                => {
      dbbackup_user     => 'postgres',
      dbbackup_password => '',
      dumper            => 'pg_dump',
      dump_flags        => '-Fc',
      ignore_dbs        => [ 'postgres' ],
      compress          => 'pbzip2',
    },
    misc         => {
      commands   => $::osfamily ? {
        'RedHat' =>  [
          'rpm -qa --qf="%{name}," > packages.txt',
        ],
        'Debian' => [
          'dpkg --get-selections > packages.txt',
        ],
        default => [],
      },
    },
  }
}
