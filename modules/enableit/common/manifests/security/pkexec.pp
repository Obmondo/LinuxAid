# CVE-2021-4034 polkit pkexec vuln
#
# Adds or removes suid bits on pkexec binary
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
    mode => $_mode,
    noop => $noop_value,
  }

}
