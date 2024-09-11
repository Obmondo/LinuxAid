# Export
define nfs::export (
  $clients,
  $path    = $name,
  $options = [ 'rw', 'sync', 'no_subtree_check', ],
) {

  concat::fragment { $name:
    target  => '/etc/exports',
    content => template('nfs/exports.fragment.erb'),
  }

}
