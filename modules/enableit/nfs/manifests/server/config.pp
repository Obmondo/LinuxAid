# NFS config
class nfs::server::config (
  Boolean $ensure = true,
  Stdlib::Absolutepath $defaults_path, # from hiera
) {

  file { $defaults_path:
    ensure  => ensure_file($ensure),
    content => epp('nfs/nfs.conf.epp'),
    notify  => Service[$::nfs::server::service_name],
  }

  concat { '/etc/exports':
    ensure => if $ensure { 'present' } else { 'absent' },
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    warn   => true,
    notify => Service[$::nfs::server::service_name],

  }
}
