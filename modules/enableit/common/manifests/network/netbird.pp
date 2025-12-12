# @summary Class for managing Netbird Agent
#
# @param setup_key The setup key used for authentication.
#
# @param enable Boolean to enable or disable the Netbird agent.
#
# @param noop_value Optional boolean to enable no-operation mode.
#
# @param server The HTTPS URL of the Netbird server. Defaults to 'https://netbird.obmondo.com:443'.
#
# @param version
#   The Netbird version to install. The default is the type Eit_types::Version.
#   Link to netbird client releases page: https://github.com/netbirdio/netbird/releases
#
# @example Valid Netbird client version  
#   version = "0.59.3"
#
# @param install_method The method to install Netbird. The default is to download via their GitHub repo releases.
#
class common::network::netbird (
  Boolean                  $enable,
  Stdlib::HTTPSUrl         $server,
  Eit_types::Version       $version,
  String                   $setup_key,
  Enum['package', 'repo']  $install_method,
  Eit_types::Noop_Value    $noop_value =  undef,
) {
  include profile::network::netbird
}
