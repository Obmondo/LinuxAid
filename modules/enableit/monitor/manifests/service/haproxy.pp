# @summary Class for managing Haproxy Alerts
#
class monitor::service::haproxy () {
  contain monitor::service::haproxy::backend_down
  contain monitor::service::haproxy::backend_response_time
  contain monitor::service::haproxy::requests_denied
}
