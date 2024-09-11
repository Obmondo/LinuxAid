function vsftpd::bool2vsftpd(Boolean $arg) >> String {
  case $arg {
    false, undef, /(?i:false)/ : { 'NO' }
    true, /(?i:true)/          : { 'YES' }
    default                    : { $arg }
  }
}
