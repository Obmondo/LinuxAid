# == Class uwsgi::service
#
# This class is meant to be called from uwsgi.
# It ensure the service is running.
#
class uwsgi::service {

  service { $::uwsgi::service_name:
    ensure     => $::uwsgi::service_ensure,
    enable     => $::uwsgi::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
