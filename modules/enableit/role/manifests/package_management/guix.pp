# Guix
class role::package_management::guix (
  Optional[Eit_types::SimpleString] $listen_interface,
  Optional[Array[Stdlib::Host]]     $clients,
) {

  class { 'profile::package_management::guix':
    listen_interface => $listen_interface,
    clients           => $clients,
  }
}
