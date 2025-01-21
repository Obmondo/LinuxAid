# RHEL package NFS
class nfs::client::rhel::packages (
    $ensure = installed,
) {

    package { 'nfs-utils':
        ensure => $ensure,
    }

    if $facts['os']['release']['major'] < 7 {
        package { 'nfs-utils-lib':
            ensure => $ensure,
        }
    }
}
