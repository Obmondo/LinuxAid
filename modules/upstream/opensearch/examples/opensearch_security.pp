# OpenSearch security plungin will bootstrap its configuartion on first start.
#
# Changing these files after the first start will have no effect, this is
# currently out-of-scope for the module.  See the following link for details:
#
# https://opensearch.org/docs/latest/security/configuration/security-admin/

# This example install opensearch and replace the default internal users with
# custom ones.
class { 'opensearch':
  use_default_security_internal_users => false,
  security_internal_users             => {
    _meta  => {
      type           => 'internalusers',
      config_version => 2,
    },
    admin  => {
      hash          => '$2y$12$mGgkt/wdhC/hMjozXcskf.Vq90HzzvEQfr32yHDxOUWZcU6JadM0C',
      reserved      => true,
      backend_roles => [
        'admin',
      ],
      description   => 'The admin user with a secret password',
    },
    puppet => {
      hash        => '$2y$12$HQ16b5CUG9yp81oEe1r4w.y3Rs/T7SR5D41BtU.OYR/PoVzKBh856',
      reserved    => false,
      description => 'A puppet user with a secret password',
    },
  },
}
