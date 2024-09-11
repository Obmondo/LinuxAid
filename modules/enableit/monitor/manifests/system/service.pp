# Systemd services
class monitor::system::service (
) {

  contain monitor::system::service::down
  contain monitor::system::service::lsof
  contain monitor::system::service::smartmon
  contain monitor::system::service::ssacli
  contain monitor::system::service::dellhw
}
