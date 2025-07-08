# @summary Class for Obmondo system monitoring
#
class monitor::service (
) {
  contain monitor::service::haproxy
}
