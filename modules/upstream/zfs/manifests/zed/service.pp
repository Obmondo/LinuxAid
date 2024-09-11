# @!visibility private
class zfs::zed::service {

  if $zfs::zed::service_manage {
    service { $zfs::zed::service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
