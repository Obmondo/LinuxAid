# EnableIT custom elk module
class eit_elk::curator_configfile (
  $operation,
  $daysold,
  $indexpattern,
  $esmajver = 2, #hardcode to es >2.x
) {
  if ( $esmajver == 2 ) {
    if ( ! defined(File['/etc/curator']) ) {
      file { '/etc/curator': ensure => directory }
    }
    file { "/etc/curator/curator-${operation}-${indexpattern}.action": content => template("eit_elk/curator-${operation}.erb") }
  } else {
    fail("unsupported ${esmajver}")
  }

}

