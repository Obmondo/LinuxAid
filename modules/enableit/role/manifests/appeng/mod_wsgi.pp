
# @summary Class for managing the Uwsgi role
#
# @param domains The array of FQDNs for the application.
#
# @param ssl Specifies whether to enable SSL. Defaults to false.
#
# @groups application domains
#
# @groups security ssl
#
class role::appeng::mod_wsgi (
  Array[Stdlib::Fqdn] $domains,
  Boolean             $ssl = false,
) inherits ::role::appeng {

  contain ::profile::web::python

  class { 'profile::appeng::wsgi':
    domains     => $domains,
    ssl         => $ssl,
    mod_wsgi    => true,
    http_server => 'apache',
  }
}
