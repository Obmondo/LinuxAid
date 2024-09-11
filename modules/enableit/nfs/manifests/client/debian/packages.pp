# DEBIAN package NFS
class nfs::client::debian::packages (
    $ensure = installed,
) {

    package { 'nfs-common':
        ensure => $ensure,
    }

}
