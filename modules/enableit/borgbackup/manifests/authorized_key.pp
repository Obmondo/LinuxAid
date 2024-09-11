#
# Internal define to handle the authorized keys
# from borgbackup::server
#
# for borgbackup dokumentation see:
#   http://borgbackup.readthedocs.io/en/stable/usage/serve.html
#
# Parameters:
#   $backuproot
#     the directory where all the backups should be
#   $target
#     the target authorized_keys file
#   $command
#     the command to restrict to
#     defaults to 'borg serve'
#   $reponame
#     the name of the repo, defaults to $title
#   $keys
#     the ssh public keys to grant access with this configuration
#     defaults to []
#   $restrict_to_path
#     restrict repository access to PATH. 
#     Access to all sub-directories is granted implicitly;
#     can be set to:
#     '' or no: option not used
#     'yes': set to ${backuproot}/${reponame}
#     or any path to set.
#     defaults to 'no'
#   $restrict_to_repository
#     restrict repository access. Only the repository located at 
#     PATH (no sub-directories are considered) is accessible.
#     can be set to:
#     '' or no: option not used
#     'yes': set to ${backuproot}/${reponame}
#     or any path to set.
#     defaults to 'yes'
#   $append_only
#     only allow appending to repository segment files
#     Defaults to false
#   $storage_quota
#     Override storage quota of the repository (e.g. 5G, 1.5T).
#     When a new repository is initialized, sets the storage quota 
#     on the new repository as well. Default: no quota.
#   $restricts
#     ssh restrictions to set. 
#     defaults to ['restrict'] this needs openssh-server > 7.2
#     if openssh-server < 7.2 use:
#     ['no-port-forwarding','no-X11-forwarding','no-pty',
#      'no-agent-forwarding','no-user-rc']
#   $env_vars
#     Hash of environment variables to set  
#     defaults to {}
#
define borgbackup::authorized_key (
  String  $backuproot,
  String  $target,
  String  $command                = 'borg serve',
  String  $reponame               = $title,
  Array   $keys                   = [],
  String  $restrict_to_path       = 'no',
  String  $restrict_to_repository = 'yes',
  Boolean $append_only            = false,
  String  $storage_quota          = '',
  Array   $restricts              = ['restrict'],
  Hash    $env_vars               = {},
) {

  case $restrict_to_repository {
    'yes': {
      $_restrict_to_repository = " --restrict-to-repository ${backuproot}/${reponame}"
    }
    'no' : {
      $_restrict_to_repository = ''
    }
    '' : {
      $_restrict_to_repository = ''
    }
    default: {
      $_restrict_to_repository = " --restrict-to-repository ${restrict_to_repository}"
    }
  }

  case $restrict_to_path {
    'yes': {
      $_restrict_to_path = " --restrict-to-path ${backuproot}/${reponame}"
    }
    'no': {
      $_restrict_to_path = ''
    }
    '': {
      $_restrict_to_path = ''
    }
    default: {
      $_restrict_to_path = " --restrict-to-path ${restrict_to_path}"
    }
  }

  if $append_only {
    $_append_only = ' --append-only'
  } else {
    $_append_only = ''
  }

  if $storage_quota == '' {
    $_storage_quota = ''
  } else {
    $_storage_quota = " --storage-quota ${storage_quota}"
  }

  $borg_cmd = "${command}${_restrict_to_path}${_restrict_to_repository}${_append_only}${_storage_quota}"

  concat::fragment{ $title:
    target  => $target,
    content => template('borgbackup/authorized_key.erb'),
    order   => $title,
  }
}
