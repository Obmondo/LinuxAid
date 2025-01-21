# Borg Push (Client) Server
# Which is going to push backup to borg::server
define common::backup::borg::push (
  Array[Stdlib::Absolutepath]             $archives,
  Optional[Eit_types::User]               $remote_user        = $::common::backup::borg::remote_user,
  Variant[Eit_types::IP, Stdlib::FQDN]    $remote_ip          = $::common::backup::borg::remote_ip,
  Optional[Eit_types::Password]           $password           = undef,
  Stdlib::Absolutepath                    $remote_backup_root = $::common::backup::borg::remote_backup_root,
  Optional[Eit_types::SystemdTimeSpan]    $randomized_delay   = $::common::backup::borg::randomized_delay,
  Optional[Eit_types::SystemdTime]        $timespec           = $::common::backup::borg::timespec,
) {

  $_ssh_key_file = '/etc/obmondo/borg/borg_id_rsa'
  $_reponame     = $name
  $_backup_root  = "${remote_backup_root}/${facts['networking']['hostname']}"

  ::borgbackup::archive { $_reponame :
    reponame        => $_reponame,
    create_includes => $archives,
  }

  ::borgbackup::repo { $_reponame:
    reponame       => $_reponame,
    remote_user    => $remote_user,
    remote_ip      => $remote_ip,
    backup_root    => $_backup_root,
    passphrase     => $password,
    ssh_key_file   => $_ssh_key_file,
    passcommand    => '',
    env_vars       => {
      'BORG_RSH' => "ssh -i ${_ssh_key_file} -o BatchMode=yes",
    },
    crontab_define => 'common::services::systemd',
    crontabs       => {
      "obmondo-backup-borg@${_reponame}.timer" => {
        ensure  => true, #lint:ignore:ensure_first_param
        enable  => true,
        unit    => {
          'Description' => 'Obmondo borg backup',
        },
        timer   => {
          'OnCalendar'         => systemd_make_timespec($timespec),
          'RandomizedDelaySec' => $randomized_delay,
          'Persistent'         => 'true', # lint:ignore:quoted_booleans
        },
        install => {
          'WantedBy' => 'timers.target',
        },
      },
    },
    check_host     => undef,
  }
}
