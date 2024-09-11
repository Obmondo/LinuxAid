#
# this class is used to setup a remote borg server
# (the target) where to put the backups
# 
# Parameters:
#  $backuproot
#    directory for the backups.
#    defaults to '/srv/borgbackup'
#  $borguser
#    the user to create for the remote borg 'agents'
#    to login via ssh
#    defaults to 'borgbackup'
#  $borggroup
#    the group of the borguser
#    defaults to 'borgbackup'
#  $user_ensure
#    if true (default) the $borguser is created
#  $authorized_keys_define   = '',
#    resource to create the authorized-keys file
#    defaults to 'borgbackup::authorized_key'
#    if you do not want to manage the authorized-keys file
#    set this to ''
#  $authorized_keys         = {},
#    Hash of keys to add to authorized-keys file
#    defaults to {}
#  $authorized_keys_defaults = {},
#    Hash of default parameters to generate the 
#    authorized-keys file
#    defaults to {}
#
class borgbackup::server(
  String  $backuproot               = '/srv/borgbackup',
  String  $borguser                  = 'borgbackup',
  String  $borggroup                = 'borgbackup',
  String  $borghome                 = '/var/lib/borgbackup',
  Boolean $user_ensure              = true,
  String  $authorized_keys_target   = '/var/lib/borgbackup/authorized-keys',
  String  $authorized_keys_define   = 'borgbackup::authorized_key',
  Hash    $authorized_keys          = {},
  Hash    $authorized_keys_defaults = {},
){

  if $user_ensure {
    user{ $borguser:
      ensure     => present,
      comment    => 'borgbackup user',
      managehome => true,
      home       => $borghome,
      system     => true,
      before     => File[$backuproot],
    }
  }

  file { $backuproot:
    ensure => 'directory',
    owner  => $borguser,
    group  => $borggroup,
    mode   => '0700',
  }

  if $authorized_keys_define == 'borgbackup::authorized_key' {
    # initalize our define for authorized keys
    $_authorized_keys_defaults = merge($authorized_keys_defaults, {
        target     => $authorized_keys_target,
        backuproot => $backuproot,
      }
    )
    concat{ $authorized_keys_target:
      owner => $borguser,
      group => $borggroup,
      mode  => '0644',
    }
  } else {
    # use another define for generating authorized keys
    # in this case to not add our defaults
    $_authorized_keys_defaults = $authorized_keys_defaults
  }

  # create the authorized key
  if $authorized_keys_define != '' {
    create_resources($authorized_keys_define, $authorized_keys, $_authorized_keys_defaults)
  }
}


