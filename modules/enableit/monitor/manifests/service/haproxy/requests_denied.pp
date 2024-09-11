# haproxy alerts for ddos protection
class monitor::service::haproxy::requests_denied (
  Boolean $enable = false,
) inherits monitor::service::haproxy {

  @@monitor::alert { 'monitor::service::haproxy::requests_denied_mild':
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::alert { 'monitor::service::haproxy::requests_denied_severe':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
