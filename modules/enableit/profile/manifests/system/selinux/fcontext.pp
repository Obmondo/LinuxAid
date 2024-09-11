#
define profile::system::selinux::fcontext (
  String                                       $pathspec = $title,
  Eit_types::Ensure                            $ensure   = 'present',
  Optional[String]                             $seltype  = undef,
  Optional[String]                             $seluser  = undef,
  Enum['a', 'f', 'd', 'c', 'b', 's', 'l', 'p'] $filetype = 'a',
) {

  selinux::fcontext { $pathspec :
    ensure   => $ensure,
    seltype  => $seltype,
    seluser  => $seluser,
    filetype => $filetype,
  }

  # NOTE: Dropping this, since its taking too much of time
  # 1. refreshonly needs to be set false, because of subscribe/notify is set to anchor inside upstream module.
  # 2. The restorecon needs to full path, so path like /tmp/abc(/.*)? fails
#  selinux::exec_restorecon { $pathspec :
#    refreshonly => false,
#    unless      => "/bin/stat --format=%C ${pathspec} | /bin/cut -d ':' -f 3 | /bin/grep ${seltype}",
#  }
}
