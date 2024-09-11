#
# borg backup class
#
# Parameters:
#  $configdir
#    configuration directory
#    defaults to '/etc/borgbackup'
#  $ensure_ssh_directory
#    if we true (default) we create the .ssh directory
#  $ssh_key_define
#    the resource to use for the generation of an ssh key
#    defaults to ''
#  $ssh_key_res
#    the parameters to use for the $ssh_key_define
#    defaults to {}
#  $repos
#    Hash of repos to create (also see borgbackup::repo for
#    parameters.
#    defautls to {$::fqdn => {}} which creates an
#    empty repo named $::fqdn.
#  $default_target
#    the default target of the backup for $repos definition
#    defaults to ''
#    see ::borgbackup::repo
#  $repos_defaults
#    default values for the $repos to create.
#    defaults to {}
#
class borgbackup (
  String  $configdir            = '/etc/borgbackup',
  Optional[Stdlib::AbsolutePath]  $last_borgbackup = '/var/tmp',
  Boolean $ensure_ssh_directory = true,
  String  $ssh_key_define       = '',
  Hash    $ssh_key_res          = {},
  Hash    $repos                = {$::fqdn => {}},
  String  $default_target       = '',
  Hash    $repos_defaults       = {},
) {

  include ::borgbackup::install

  # create a configuration directory
  file { $configdir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $ensure_ssh_directory {
    file { "${configdir}/.ssh":
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }
  }

  if $ssh_key_define != '' {
    create_resources($ssh_key_define, $ssh_key_res)
  }

  $_repos_defaults = merge(
    $repos_defaults,
    {
      target => $default_target,
    }
  )

  create_resources('::borgbackup::repo', $repos, $_repos_defaults)
}
