
# @summary Class for managing the UWSGI role
#
# @param domains The list of fully qualified domain names. 
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @groups services ssl
#
# @groups networking domains
#
class role::appeng::uwsgi (
  Array[Stdlib::Fqdn]     $domains,
  Boolean                 $ssl = false,
) inherits ::role::appeng {

  contain ::profile::web::python

  class { 'profile::appeng::wsgi' :
    domains     => $domains,
    ssl         => $ssl,
    uwsgi       => true,
    http_server => 'nginx',
  }
}
