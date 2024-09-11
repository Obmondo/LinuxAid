# @api private
#
# @summary Setup any token file or webserver index
#
# @param manage_service_config
#   should this clas manage any config files?
# @param websockify_config_dir
#   where are config files kept
# @param websockify_config_mode
#   where permissions should the configs have
# @param websockify_token_plugin
#   what type of token plugin is in use
# @param websockify_token_source
#   what is the data source for the token plugin
#   if $websockify_token_plugin == 'TokenFile', this should be the filename
# @param websockify_service_user
#   User to run the service as
# @param websockify_service_group 
#   Group to run the service as
# @param make_webserver_vnc_index 
#   Make a simple index file listing out known sessions
# @param webserver_novnc_location
#   What is the URL base for novnc (probably /novnc)
# @param webserver_vnc_index
#   Where should we write out the known session index?
# @param vnc_servers
#   What VNC servers should we connect to?
#
class vnc::client::novnc::config (
  # lint:ignore:parameter_types
  $manage_service_config = $vnc::client::novnc::manage_service_config,
  $websockify_config_dir = $vnc::client::novnc::websockify_config_dir,
  $websockify_config_mode = $vnc::client::novnc::websockify_config_mode,
  $websockify_token_plugin = $vnc::client::novnc::websockify_token_plugin,
  $websockify_token_source = $vnc::client::novnc::websockify_token_source,
  $websockify_service_user = $vnc::client::novnc::websockify_service_user,
  $websockify_service_group = $vnc::client::novnc::websockify_service_group,

  $make_webserver_vnc_index = $vnc::client::novnc::make_webserver_vnc_index,
  $webserver_novnc_location = $vnc::client::novnc::webserver_novnc_location,
  $webserver_vnc_index = $vnc::client::novnc::webserver_vnc_index,

  $vnc_servers = $vnc::client::novnc::vnc_servers,
  # lint:endignore
) inherits vnc::client::novnc {
  assert_private()

  $vnc_sessions = Hash(flatten($vnc_servers.map |$key, $value| { [$key, { 'token' => stdlib::crc32("${key} ${value}"), 'connection' => $value }] }))   # lint:ignore:140chars

  if $manage_service_config {
    file { $websockify_config_dir:
      ensure => 'directory',
      owner  => 'root',
      group  => $websockify_service_group,
      mode   => $websockify_config_mode,
    }

    if $websockify_token_plugin == 'TokenFile' or $websockify_token_plugin == 'ReadOnlyTokenFile' {
      file { $websockify_token_source:
        ensure  => 'file',
        owner   => 'root',
        group   => $websockify_service_group,
        mode    => $websockify_config_mode,
        content => epp('vnc/etc/websockify/websockify-token.cfg.epp', { 'vnc_sessions' => $vnc_sessions }),
      }
    }
  }

  if $make_webserver_vnc_index {
    file { $webserver_vnc_index:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/var/www/novnc_users_list.html.epp', { 'vnc_sessions' => $vnc_sessions, 'novnc_location' => $webserver_novnc_location }),   # lint:ignore:140chars
    }
  }
}
