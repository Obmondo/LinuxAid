# @summary Class for relocating /tmp directory to a specified path
#
# @param relocate_to The absolute path to move /tmp to. An Optional[Stdlib::Absolutepath]. Defaults to undef.
#
class common::system::relocatetmp (
  Optional[Stdlib::Absolutepath] $relocate_to = undef,
) {
  if $relocate_to {
    file { '/usr/local/sbin/move_tmp.sh':
      ensure  => file,
      owner   => 'root',
      mode    => 'a+x',
      content => epp('common/system/move_tmp.sh.epp', {
        relocate_to => $relocate_to,
      }),
    }
    exec { "move /tmp to ${relocate_to}":
      path    => [ '/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin', '/usr/local/sbin' ],
      command => 'move_tmp.sh',
    }
  }
}
