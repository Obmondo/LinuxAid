# == Class: rsnapshot::config
#
# manage host configs
class rsnapshot::config (
  $hosts          = $rsnapshot::hosts,
  $cron_dir       = $rsnapshot::cron_dir,
) {

  # these are global settings, no point in setting them per host
  $config_version         = $rsnapshot::params::config_version
  $lockpath               = pick($rsnapshot::lockpath, $rsnapshot::params::config_lockpath, '/var/run/rsnapshot')
  $conf_d                 = pick($rsnapshot::conf_d, $rsnapshot::params::conf_d, '/etc/rsnapshot')
  $snapshot_root          = pick($hosts['snapshot_root'], $rsnapshot::snapshot_root, '/backup')
  $logpath                = pick($rsnapshot::logpath, $rsnapshot::params::config_logpath)
  # make sure lock path and conf path exist
  file { $conf_d:
    ensure => 'directory',
  }
  file { $lockpath:
    ensure => 'directory',
  }
  file { $cron_dir:
    ensure => 'directory',
  }
  file { $snapshot_root:
    ensure => 'directory',
  }
  file { $logpath:
    ensure => directory,
  }

  # custom function, if only a hostname is given as a param, this is an empty hash
  # the next loop would break as puppet does not allow to reassign variables
  # the function checks $hosts for elements like: 
  # { foo => } and converts those to { foo => {} }
  $hosts_clean = assert_empty_hash($hosts)

  $hosts_clean.each |String $host, $hash | {
    $backup_user            = pick($hash['backup_user'], $rsnapshot::params::config_backup_user)
    $default_backup_dirs    = pick($rsnapshot::default_backup, $rsnapshot::params::config_default_backup)
    $backup_levels          = pick($hash['backup_levels'], $rsnapshot::backup_levels, 'weekly')
    $backup                 = $hash['backup']
    $backup_defaults        = pick($hash['backup_defaults'], $rsnapshot::params::config_backup_defaults)
    $cmd_cp                 = pick($hash['cmd_cp'], $rsnapshot::params::config_cmd_cp)
    $cmd_rm                 = pick($hash['cmd_rm'], $rsnapshot::params::config_cmd_rm)
    $cmd_rsync              = pick($hash['cmd_rsync'], $rsnapshot::params::config_cmd_rsync)
    $cmd_ssh                = pick($hash['cmd_ssh'], $rsnapshot::params::config_cmd_ssh)
    $cmd_logger             = pick($hash['cmd_logger'], $rsnapshot::params::config_cmd_logger)
    $cmd_du                 = pick($hash['cmd_du'], $rsnapshot::params::config_cmd_du)
    $cmd_rsnapshot_diff     = pick_undef($hash['cmd_rsnapshot_diff'], $rsnapshot::params::config_cmd_rsnapshot_diff)
    $cmd_preexec            = pick_undef($hash['cmd_preexec'], $rsnapshot::params::config_cmd_preexec)
    $cmd_postexec           = pick_undef($hash['cmd_postexec'], $rsnapshot::params::config_cmd_postexec)
    $use_lvm                = pick_undef($hash['use_lvm'], $rsnapshot::params::config_use_lvm)
    $linux_lvm_cmd_lvcreate = pick_undef($hash['linux_lvm_cmd_lvcreate'], $rsnapshot::params::config_linux_lvm_cmd_lvcreate)
    $linux_lvm_cmd_lvremove = pick_undef($hash['linux_lvm_cmd_lvremove'], $rsnapshot::params::config_linux_lvm_cmd_lvremove)
    $linux_lvm_cmd_mount    = pick_undef($hash['linux_lvm_cmd_mount'], $rsnapshot::params::config_linux_lvm_cmd_mount)
    $linux_lvm_cmd_umount   = pick_undef($hash['linux_lvm_cmd_umount'], $rsnapshot::params::config_linux_lvm_cmd_umount)
    $linux_lvm_snapshotsize = pick_undef($hash['linux_lvm_snapshotsize'], $rsnapshot::params::config_linux_lvm_snapshotsize)
    $linux_lvm_snapshotname = pick_undef($hash['linux_lvm_snapshotname'], $rsnapshot::params::config_linux_lvm_snapshotname)
    $linux_lvm_vgpath       = pick_undef($hash['linux_lvm_vgpath'], $rsnapshot::params::config_linux_lvm_vgpath)
    $linux_lvm_mountpath    = pick_undef($hash['linux_lvm_mountpath'], $rsnapshot::params::config_linux_lvm_mountpath)
    $no_create_root         = pick_undef($hash['no_create_root'], $rsnapshot::params::config_no_create_root)
    $verbose                = pick($hash['verbose'], $rsnapshot::params::config_verbose)
    $loglevel               = pick($hash['loglevel'], $rsnapshot::params::config_loglevel)
    $stop_on_stale_lockfile = pick_undef($hash['stop_on_stale_lockfile'], $rsnapshot::params::config_stop_on_stale_lockfile)
    $rsync_short_args       = pick($hash['rsync_short_args'], $rsnapshot::params::config_rsync_short_args)
    $rsync_long_args        = pick_undef($hash['rsync_long_args'], $rsnapshot::params::config_rsync_long_args)
    $ssh_args               = pick_undef($hash['ssh_args'], $rsnapshot::params::config_ssh_args)
    $du_args                = pick_undef($hash['du_args'], $rsnapshot::params::config_du_args)
    $one_fs                 = pick_undef($hash['one_fs'], $rsnapshot::params::config_one_fs)
    $interval               = pick($hash['interval'], $rsnapshot::params::config_interval)
    $retain                 = pick_undef($hash['retain'], $rsnapshot::params::config_retain)
    $include                = pick($hash['include'], [])
    $exclude                = pick($hash['exclude'], [])
    $include_file           = pick($hash['include_file'], $rsnapshot::params::config_include_file, "${conf_d}/${host}.include")
    $exclude_file           = pick($hash['exclude_file'], $rsnapshot::params::config_exclude_file, "${conf_d}/${host}.exclude")
    $link_dest              = pick_undef($hash['link_dest'], $rsnapshot::params::config_link_dest)
    $sync_first             = pick_undef($hash['sync_first'], $rsnapshot::params::config_sync_first)
    $use_lazy_deletes       = pick_undef($hash['use_lazy_deletes'], $rsnapshot::params::config_use_lazy_deletes)
    $rsync_numtries         = pick_undef($hash['rsync_numtries'], $rsnapshot::params::config_rsync_numtries)
    #$backup_scripts         = pick_undef($hash['backup_scripts'], $rsnapshot::params::config_backup_scripts)

    $snapshot_dir           = "${config_snapshot_root}/${host}"
    $config                 = "${conf_d}/${host}.rsnapshot.conf"
    $lockfile               = "${lockpath}/${host}.pid"
    $logfile                = "${logpath}/${host}.log"

    # fail if $backup_defaults is set to false and no $host[backup] defined
    if ! $backup_defaults and ! $backup  {
      fail("==> Configuration error: backup_defaults is ${backup_defaults} and backup definitions for this host don't exist <==")
    }

    # merge the backup hashes to one if backup_default is set (defaults to true)
    if $backup_defaults {
      $backups = merge($backup, $default_backup_dirs)
    } else {
      $backups = $backup
    }

    # one of both interval or retain must be present
    if ! ( $interval and $retain ) {
      $interval             = pick($hash['interval'], $rsnapshot::params::config_interval)
    }
    # rsnapshot wants numeric values
    if $link_dest {
      $link_dest_num        = bool2num($link_dest)
    }
    if $sync_first {
      $sync_first_num       = bool2num($sync_first)
    }
    if $use_lazy_deletes {
      $use_lazy_deletes_num = bool2num($use_lazy_deletes)
    }

    $real_include = $rsnapshot::include + $include
    unless empty($real_include)  {
      file { $include_file:
        ensure  => 'file',
        content => template('rsnapshot/include.erb'),
      }
    }

    $real_exclude = $rsnapshot::exclude + $exclude
    unless empty($real_exclude) {
      file { $exclude_file:
        ensure  => 'file',
        content => template('rsnapshot/exclude.erb'),
      }
    }

    concat { $config:
    }
    concat::fragment { "${config} for ${host}":
      target  => $config,
      content => template('rsnapshot/rsnapshot.erb'),
    }

    if has_key($hash, backup_scripts) {

      $hash[backup_scripts].each |$script, $credentials| {

        if is_hash($credentials) {
          $dbbackup_user     = $credentials['dbbackup_user']
          $dbbackup_password = $credentials['dbbackup_password']
        } else {
          $dbbackup_user     = $rsnapshot::default_backup_scripts[$script]['dbbackup_user']
          $dbbackup_password = $rsnapshot::default_backup_scripts[$script]['dbbackup_password']
        }

        concat::fragment { "${host}_${script}_backup":
          target  => $config,
          content => "backup_script	${conf_d}/${host}.${script}.sh	./${script}\n",
        }

        file { "${conf_d}/${host}.${script}.sh":
          ensure  => present,
          content => template("rsnapshot/${script}.sh.erb"),
          mode    => '0755',
        }
        
      }
    }

    $cronfile = "${cron_dir}/${host}"
    concat { $cronfile:
    }
    # create cron files for each backup level
    # merge possible cron definitions to one
    $real_cron = deep_merge($rsnapshot::params::cron, $rsnapshot::cron, $hash[cron])

    $backup_levels.each |String $level| {
      $minute   = rand_from_array($real_cron[$level][minute],   "${host}.${level}.minute")
      $hour     = rand_from_array($real_cron[$level][hour],     "${host}.${level}.hour")
      $monthday = rand_from_array($real_cron[$level][monthday], "${host}.${level}.monthday")
      $month    = rand_from_array($real_cron[$level][month],    "${host}.${level}.month")
      $weekday  = rand_from_array($real_cron[$level][weekday],  "${host}.${level}.weekday")

      concat::fragment { "${host}.${level}":
        target  => $cronfile,
        content => template('rsnapshot/cron.erb'),
      }
    }
  }
}

