
# @summary Class for managing the Uwsgi role
#
# @param domains The array of FQDNs for the application.
#
# @param ssl Specifies whether to enable SSL. Defaults to false.
#
# @param enable_python Specifies whether to enable Python support. Defaults to true.
#
# @groups application domains, enable_python
#
# @groups security ssl
#
class role::appeng::mod_wsgi (
  Array[Stdlib::Fqdn] $domains,
  Boolean              $ssl         = false,
  Boolean              $enable_python = true,
) inherits ::role::appeng {

  if $enable_python {
    contain ::profile::python
  }

  class { 'profile::wsgi':
    domains     => $domains,
    ssl         => $ssl,
    mod_wsgi    => true,
    http_server => 'apache',
  }
}
