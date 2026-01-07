# @summary Class for monitoring HAProxy backend response times
#
# @param enable Boolean to enable or disable the monitoring. Defaults to true.
#
# @groups enable enable
#
class monitor::service::haproxy::backend_response_time (
  Boolean $enable = true,
) inherits monitor::service::haproxy {
  @@monitor::alert { 'monitor::service::haproxy::backend_response_time':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
