# RHEL Client NFS
class nfs::client::rhel (
    $ensure = installed,
) {

    require portmap

    anchor { 'nfs::client::rhel::begin': }

    class { 'nfs::client::rhel::packages':
        ensure => $ensure,
    }

    anchor { 'nfs::client::rhel::end': }

}
