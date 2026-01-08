# @summary Class for setting up Borg backup and installing necessary packages
#
# @param __dir The absolute path to the backup configuration directory.
#
# @param prune_keep Hash defining retention periods for daily, weekly, and monthly backups. Defaults to {'daily' => 7, 'weekly' => 2, 'monthly' => 2}.
#
# @param timespec Hash specifying the schedule time. Defaults to { 'weekday' => undef, 'year' => '*', 'month' => '*', 'day' => '*', 'hour' => 02, 'minute' => 0, 'second' => 0 }.
#
# @param randomized_del Optional delay to introduce randomness in schedule. Defaults to '10 minutes'.
#
# @param remote_user Optional user for remote backups. Defaults to $::common::backup::backup_user.
#
# @param remote_ip Optional IP address for remote backup destination.
#
# @param remote_backup_root Optional path for remote backup root.
#
# @param backup_root Path for local backup root. Defaults to $::common::backup::dump_dir.
#
# @param repos Hash of repositories to backup.
#
# @param archives Array of archive paths to include in backup.
#
# @param authorized_keys Optional hash of authorized keys for remote backup.
#
# @param server Boolean indicating whether this node is a backup server. Defaults to false.
#
# @param last_borgbackup Path to store last backup timestamp. Defaults to '/var/tmp'.
#
# @param randomized_delay Randomized delay
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups config __dir, prune_keep, timespec, randomized_delay, last_borgbackup
#
# @groups remote remote_user, remote_ip, remote_backup_root, authorized_keys
#
# @groups local backup_root, repos, archives
#
# @groups server server
#
# @groups encryption encrypt_params
#
class common::backup::borg (
  Stdlib::Absolutepath                 $__dir,
  Eit_types::Borg_prune_numbers        $prune_keep = {
    'daily'   => 7,
    'weekly'  => 2,
    'monthly' => 2,
  },
  Eit_types::SystemdTime               $timespec   = {
    'weekday' => undef,
    'year'    => '*',
    'month'   => '*',
    'day'     => '*',
    'hour'    => 02,
    'minute'  => 0,
    'second'  => 0,
  },
  Optional[Eit_types::SystemdTimeSpan]              $randomized_delay   = '10 minutes',
  Optional[Eit_types::User]                         $remote_user        = $::common::backup::backup_user,
  Optional[Variant[Eit_types::IP, Stdlib::FQDN]]    $remote_ip          = undef,
  Optional[Stdlib::Absolutepath]                    $remote_backup_root = undef,
  Stdlib::Absolutepath                              $backup_root        = $::common::backup::dump_dir,
  Hash                                              $repos              = {},
  Array[Stdlib::Absolutepath]                       $archives           = [],
  Optional[Hash]                                    $authorized_keys    = undef,
  Boolean                                           $server             = false,
  Optional[Stdlib::Absolutepath]                    $last_borgbackup    = '/var/tmp',
  Eit_types::Encrypt::Params                        $encrypt_params     = ['repos.*.password'],
) inherits common::backup {
  class { '::borgbackup' :
    configdir            => $__dir,
    last_borgbackup      => $last_borgbackup,
    ensure_ssh_directory => false,
    repos                => {},
    repos_defaults       => {},
  }
  if $server {
    confine(!$authorized_keys, $server, 'Need authorization key to accept backup from clients')
    $authorized_keys.each |$authorized_keys, $param| {
      # Content configuration for authorized keys
      file { '/etc/borg':
        ensure  => present,
        content => "BORG_PASSPHRASE=${param['password']}\nREPOSITORY=/data/borg/${authorized_keys}\nCOLLECTOR_DIR=/var/lib/node_exporter/textfile_collector\n", #lint:ignore:140chars
      }
    }
    package { 'obmondo-borg-exporter' :
      ensure => present
    }
    service { 'borg-exporter.timer' :
      ensure  => running,
      enable  => true,
      require => Package['obmondo-borg-exporter'],
    }
    common::backup::borg::server { $facts['networking']['hostname'] :
      backup_root     => $backup_root,
      authorized_keys => $authorized_keys,
    }
  } else {
    ## services
    common::services::systemd { 'obmondo-backup-borg@.service':
      ensure  => false,
      enable  => false,
      unit    => {
        'Description' => 'Obmondo borg backup',
      },
      service => {
        'Type'          => 'oneshot',
        'ExecStart'     => "/bin/bash ${__dir}/repo_%i.sh run",
        'ExecStartPost' => "/bin/bash ${__dir}/repo_%i.sh check_icinga",
        'TimeoutSec'    => 3600,
      },
      install => {
        'WantedBy' => 'default.target',
      },
    }
    $repos.each |$k, $v| {
      common::backup::borg::push { $k:
        * => $v,
      }
    }
  }
}
