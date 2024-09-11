# storage
class common::system::package_management::guix::client (
  Boolean      $enable        = false,
  Boolean      $manage_mounts = true,
  Stdlib::Host $server        = 'localhost',
) {

  contain ::profile::package_management::guix::client
}
