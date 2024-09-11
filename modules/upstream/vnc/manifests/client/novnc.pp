# @summary Setup a websocket service for running the NoVNC interface
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc server packages
# @param manage_service_config
#   should this clas manage any config files?
# @param websockify_config_dir
#   where are config files kept
# @param websockify_config_mode
#   what should the config mode be
# @param websockify_token_plugin
#   what type of token plugin is in use
# @param websockify_token_source
#   what is the data source for the token plugin
#   if $websockify_token_plugin == 'TokenFile' or 'ReadOnlyTokenFile', this should be the filename
# @param websockify_auth_plugin
#   what type of auth plugin is in use
# @param websockify_auth_source
#   what is the data source for the auth plugin
# @param websockify_service_user
#   User to run the service as
# @param websockify_service_group
#   Group to run the service as
# @param websockify_service_dynamicuser
#   Use systemd dynamic users for this service
# @param make_webserver_vnc_index
#   Make a simple index file listing out known sessions
# @param webserver_novnc_location
#   What is the URL base for novnc (probably /novnc)
# @param webserver_vnc_index
#   Where should we write out the known session index?
# @param manage_service
#   Should this service be managed
# @param websockify_command
#   where is /usr/bin/websockify?
# @param websockify_service_name
#   Name of service to manage
# @param websockify_service_ensure
#   Ensure for service
# @param websockify_service_enable
#   Enable for service
# @param websockify_port
#   Port to listen on
# @param websockify_webroot
#   Webroot for service to use
# @param websockify_prefer_ipv6
#   Try IPv6 before IPv4
# @param websockify_use_ssl
#   Use an SSL certificate for websockify
# @param websockify_use_ssl_only
#   Only use SSL connections
# @param websockify_ssl_ca
#   SSL Certificate Authority for websockify
# @param websockify_ssl_cert
#   SSL certificate for websockify
# @param websockify_ssl_key
#   SSL key for websockify
# @param vnc_servers
#   A hash of VNC servers to connect to.
#   ie. {'session_name' => 'host:port'}
class vnc::client::novnc (
  Boolean $manage_packages,
  Array $packages,
  String $packages_ensure,

  Boolean $manage_service_config,
  Stdlib::Absolutepath $websockify_config_dir,
  String $websockify_config_mode,
  String $websockify_service_user,
  String $websockify_service_group,
  Boolean $websockify_service_dynamicuser,
  String $websockify_token_plugin,
  String $websockify_token_source,
  String $websockify_auth_plugin,
  String $websockify_auth_source,

  Boolean $make_webserver_vnc_index,
  Stdlib::Absolutepath $webserver_novnc_location,
  Stdlib::Absolutepath $webserver_vnc_index,

  Boolean $manage_service,
  String $websockify_service_name,
  String $websockify_service_ensure,
  Boolean $websockify_service_enable,
  Stdlib::Absolutepath $websockify_command,
  Variant[String, Integer[0,65535]] $websockify_port,
  Stdlib::Absolutepath $websockify_webroot,
  Boolean $websockify_prefer_ipv6,
  Boolean $websockify_use_ssl,
  Boolean $websockify_use_ssl_only,
  Stdlib::Absolutepath $websockify_ssl_ca,
  Stdlib::Absolutepath $websockify_ssl_cert,
  Stdlib::Absolutepath $websockify_ssl_key,

  Hash $vnc_servers,
) {
  contain 'vnc::client::novnc::install'
  contain 'vnc::client::novnc::config'
  contain 'vnc::client::novnc::service'

  Class['vnc::client::novnc::install'] -> Class['vnc::client::novnc::config'] ~> Class['vnc::client::novnc::service']
  Class['vnc::client::novnc::install'] ~> Class['vnc::client::novnc::service']
}
