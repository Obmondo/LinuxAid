function thinlinc::ensure_log_dir(Stdlib::Absolutepath $log_file) {
  unless $log_file {
    return undef
  }

  $_log_dir = if $log_file =~ /\/$/ {
    $log_file
  } else {
    $log_file.dirname
  }

  $_dirs = $_log_dir.thinlinc::dir_to_dirs

  ensure_resource('file', $_dirs, {
    ensure => 'directory',
  })

}
