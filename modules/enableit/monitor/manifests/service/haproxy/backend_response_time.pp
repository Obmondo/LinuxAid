# haproxy backend response time
class monitor::service::haproxy::backend_response_time (
  Boolean $enable = true,
) inherits monitor::service::haproxy {

  @@monitor::alert { 'monitor::service::haproxy::backend_response_time':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
