# nfs export
define profile::storage::nfs::server::export (
  Array[String[1]]      $options,
  Variant[
    Enum['*'],
    Array[Stdlib::Host]
  ]                     $clients,
  Stdlib::Absolutepath  $path = $name,
) {

  include ::profile::storage::nfs::server

  nfs::export { $name:
    path    => $path,
    options => $options,
    clients => $clients
  }

  $_source_ips = pick($clients, '*')

  firewall_multi { "000 allow nfs clients ${title}":
    jump    => 'accept',
    iniface => $::profile::storage::nfs::server::listen_interface,
    source  => $_source_ips,
    dport   => [
      $::profile::storage::nfs::server::mountd_port,
      $::profile::storage::nfs::server::nfs_port,
    ],
    proto   => ['tcp', 'udp'],
  }

}
