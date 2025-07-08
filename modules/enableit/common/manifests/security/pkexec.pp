# @summary Class for managing the CVE-2021-4034 polkit pkexec vulnerability
#
# @param setuid Whether to add or remove the suid bit on the pkexec binary. Defaults to true.
#
# @param noop_value Optional. If set, Puppet will not modify the file system but will simulate changes.
#
class common::security::pkexec (
  Boolean           $setuid     = true,
  Optional[Boolean] $noop_value = undef,
) {
  $_mode = if $setuid {
    'u+s'
  } else {
    'u-s,g-s'
  }
  file { '/usr/bin/pkexec':
    mode  => $_mode,
    noop  => $noop_value,
  }
}
