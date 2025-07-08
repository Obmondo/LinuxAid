# @summary Class for managing Netbird Agent
#
# @param setup_key The setup key used for authentication.
#
# @param enable Boolean to enable or disable the Netbird agent. Defaults to false.
#
# @param noop_value Optional boolean to enable no-operation mode.
#
# @param server The HTTPS URL of the Netbird server. Defaults to 'https://netbird.obmondo.com:443'.
#
class common::network::netbird (
  String            $setup_key,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
  Stdlib::HTTPSUrl  $server     = 'https://netbird.obmondo.com:443'
) {
  include profile::network::netbird
}
