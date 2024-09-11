# NFS one_export
define nfs::one_export(
  $path = '',
  $options = [],
  $clients = [],
) {

  if (!defined(File[$path])) {
    file{ $path:
      ensure => present,
    }
  }

  nfs::export { $path:
    options => $options,
    clients => $clients,
    require => File[$path],
  }
}
