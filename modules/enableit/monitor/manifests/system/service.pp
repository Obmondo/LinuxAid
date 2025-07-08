# @summary Class for managing systemd services in the monitor module
#
class monitor::system::service () {
  contain monitor::system::service::down
  contain monitor::system::service::lsof
  contain monitor::system::service::smartmon
  contain monitor::system::service::ssacli
  contain monitor::system::service::dellhw
}
