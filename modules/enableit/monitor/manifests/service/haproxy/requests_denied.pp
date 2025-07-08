# @summary Class for haproxy alerts for ddos protection
#
# @param enable Boolean to enable or disable alerts. Defaults to false.
#
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
