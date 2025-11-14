# =Class perforce::license
#
# ==Description
# Installs perforce license.
#
class perforce::license {

  # perforce doesn't require a license and will support up to 5 users without one.
  #
  # installing a license
  # https://www.perforce.com/perforce/doc.current/manuals/p4sag/Content/P4SAG/DB5-71632.html#License
  file { "${perforce::service_root}/license" :
    ensure  => if $perforce::license_content {
      'file'
    } else {
      'absent'
    },
    owner   => $perforce::user,
    group   => $perforce::group,
    mode    => '0640',
    content => $perforce::license_content,
    require => [
      File[$perforce::service_root],
      User[$perforce::user],
      User[$perforce::group],
    ],
  }
}
