# UWSGI role
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
