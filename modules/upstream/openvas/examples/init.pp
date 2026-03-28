# Basic usage - include the openvas class
# The admin password should be provided via Hiera data:
#   openvas::admin_password: ENC[PKCS7,...]
#
# See README.md for detailed usage instructions.

include openvas

# Example with explicit parameters (password should still come from Hiera)
class { 'openvas':
  install       => true,
  expose        => true,
  compose_dir   => '/opt/openvas',
  feed_release  => '24.10',
  web_port      => 9392,
  manage_docker => true,
  # admin_password is intentionally not set here - use Hiera!
}
