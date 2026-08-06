
# @summary Class for managing the MongoDB role
#
# @param create_admin Whether to create an admin user. Defaults to false.
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @groups admin create_admin
#
# @groups security ssl
#
class role::db::mongodb (
  Boolean $create_admin = false,
  Boolean $ssl          = false,
) inherits ::role::db {

  # contained before the confines and the profile below, which read their parameters
  contain role::db::mongodb::create_admin
  contain role::db::mongodb::ssl

  confine($ssl, !$role::db::mongodb::ssl::key, 'Enabling `ssl` requires `ssl_key` to be set')
  confine(!$ssl, $role::db::mongodb::ssl::ca, '`ssl_ca` should only be used when `ssl` is enabled')

  confine($create_admin,
    !($role::db::mongodb::create_admin::admin_username
      and $role::db::mongodb::create_admin::admin_password
      and $role::db::mongodb::create_admin::admin_roles),
    'If `create_admin` is enabled, `admin_username`, `admin_password` and `admin_roles` must be set.'
  )

  confine(!$create_admin,
    $role::db::mongodb::create_admin::admin_store_credentials,
    '`create_admin` must be enabled if `admin_store_credentials` is set'
  )

  # FUTURE: When we support replication from the role, make sure to default to
  # the v1 protocol: https://jepsen.io/analyses/mongodb-3-4-0-rc3
  contain profile::db::mongodb
}
