# Netbird Agent
class common::network::netbird (
  String            $setup_key,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
  Stdlib::HTTPSUrl  $server     = 'https://netbird.obmondo.com:443'
) {

  include profile::network::netbird
}
