# @!visibility private
class zfs::config {

  file { $zfs::conf_dir:
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0644',
  }
}
