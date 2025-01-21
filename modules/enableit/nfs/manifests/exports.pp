# Exports
class nfs::exports (
  $definitions = {}
) {

  if ($facts['puppetversion'] =~ /^[12]/) {
    notify{"Your puppet version ${facts['puppetversion']} is too old to use nfs::exports. Required is puppet >= 3.0": }
  }
  else {
    include nfs::server
    create_resources(nfs::one_export, $definitions, {})
  }
}
