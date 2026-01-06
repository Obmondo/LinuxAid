
# @summary Class for managing the Guix package management role
#
# @param listen_interface The interface to listen on. Defaults to undef.
#
# @param clients The list of clients. Defaults to undef.
#
# @groups network listen_interface.
#
# @groups client_config clients.
#
class role::package_management::guix (
  Optional[Eit_types::SimpleString] $listen_interface,
  Optional[Array[Stdlib::Host]]     $clients,
) {
  class { 'profile::package_management::guix':
    listen_interface => $listen_interface,
    clients           => $clients,
  }
}
