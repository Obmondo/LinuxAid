# Mod Uwsgi Role
class role::appeng::mod_wsgi (
  Array[Stdlib::Fqdn]  $domains,
  Boolean              $ssl         = false,
  Boolean              $enable_python = true,
) inherits ::role::appeng {

  if $enable_python {
    contain ::profile::python
  }

  class { 'profile::wsgi' :
    domains     => $domains,
    ssl         => $ssl,
    mod_wsgi    => true,
    http_server => 'apache',
  }
}
