function beegfs::release_to_major(Beegfs::Release $release) {
  if $release =~ /^\d{4}/ {
    $release
  } else {
    $release.regsubst('^(\d+).*', '\1')
  }
}
