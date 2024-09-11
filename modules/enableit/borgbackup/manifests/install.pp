#
#
# @summary
# internal class borgbackup::install
# to install the packages
# (used by ::borgbackup::server and ::borgbackup)
#
# @params packages:
#    packages to install
#    defaults to ['borgbackup']
# @params package_ensure
#    defaults to 'installed'
#
class borgbackup::install (
  Array  $packages       = ['borgbackup'],
  String $package_ensure = 'installed',
){

  package{ $packages:
    ensure => $package_ensure,
    tag    => 'borgbackup',
  }
}
