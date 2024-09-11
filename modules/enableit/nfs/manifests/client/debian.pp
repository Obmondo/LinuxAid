# Debian NFS client
class nfs::client::debian (
    $ensure = installed,
) {

    require portmap

    anchor { 'nfs::client::debian::begin': }

    class { 'nfs::client::debian::packages':
        ensure => $ensure,
    }

    anchor { 'nfs::client::debian::end': }

}
