
# @summary Opensearch Business role.
#
# @param cerebro Whether to include Cerebro in the deployment. Defaults to false.
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @param dashboard Whether to include the Opensearch Dashboard. Defaults to false.
#
# @param expose Whether to expose the service. Defaults to false.
#
# @groups ssl_configuration ssl
#
# @groups service_exposure expose, dashboard, cerebro
class role::db::opensearch (
  Boolean $cerebro   = false,
  Boolean $ssl       = false,
  Boolean $dashboard = false,
  Boolean $expose    = false,
) inherits ::role::db {

  # contained before the profile below, which reads its parameters
  contain role::db::opensearch::ssl

  contain profile::db::opensearch

  if $cerebro {
    contain profile::db::elasticsearch::cerebro
  }

  # Opensearch Dashboard
  if $dashboard {
    contain profile::db::opensearch::dashboard
  }
}
