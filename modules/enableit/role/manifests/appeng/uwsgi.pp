
# @summary Class for managing the UWSGI role
#
# @param domains The list of fully qualified domain names. 
#
# @param enable_python Whether to enable Python support. Defaults to true.
#
# @param ssl Whether to enable SSL. Defaults to false.
#
class role::appeng::uwsgi (
  Array[Stdlib::Fqdn]     $domains,
  Boolean                 $enable_python = true,
  Boolean                 $ssl           = false,
) inherits ::role::appeng {

  if $enable_python {
    contain ::profile::python
  }

  class { 'profile::wsgi' :
    domains     => $domains,
    ssl         => $ssl,
    uwsgi       => true,
    http_server => 'nginx',
  }
}
