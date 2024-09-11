# @api private
#
# @summary manage the websockify service
#
class vnc::client::novnc::service (
  # lint:ignore:parameter_types
  $manage_service = $vnc::client::novnc::manage_service,
  $websockify_command = $vnc::client::novnc::websockify_command,
  $websockify_service_user = $vnc::client::novnc::websockify_service_user,
  $websockify_service_group = $vnc::client::novnc::websockify_service_group,
  $websockify_service_dynamicuser = $vnc::client::novnc::websockify_service_dynamicuser,
  $websockify_service_name = $vnc::client::novnc::websockify_service_name,
  $websockify_service_ensure = $vnc::client::novnc::websockify_service_ensure,
  $websockify_service_enable = $vnc::client::novnc::websockify_service_enable,
  $websockify_auth_plugin = $vnc::client::novnc::websockify_auth_plugin,
  $websockify_auth_source = $vnc::client::novnc::websockify_auth_source,
  $websockify_token_plugin = $vnc::client::novnc::websockify_token_plugin,
  $websockify_token_source = $vnc::client::novnc::websockify_token_source,
  $websockify_port = $vnc::client::novnc::websockify_port,
  $websockify_webroot = $vnc::client::novnc::websockify_webroot,
  $websockify_prefer_ipv6 = $vnc::client::novnc::websockify_prefer_ipv6,
  $websockify_use_ssl = $vnc::client::novnc::websockify_use_ssl,
  $websockify_use_ssl_only = $vnc::client::novnc::websockify_use_ssl_only,
  $websockify_ssl_ca = $vnc::client::novnc::websockify_ssl_ca,
  $websockify_ssl_cert = $vnc::client::novnc::websockify_ssl_cert,
  $websockify_ssl_key = $vnc::client::novnc::websockify_ssl_key,
  # lint:endignore
) inherits vnc::client::novnc {
  assert_private()

  if $websockify_service_ensure == 'running' {
    $active = true
  } else {
    $active = false
  }

  $template_params = {
    'websockify_command'             => $websockify_command,
    'websockify_service_user'        => $websockify_service_user,
    'websockify_service_group'       => $websockify_service_group,
    'websockify_service_dynamicuser' => $websockify_service_dynamicuser,
    'websockify_auth_plugin'         => $websockify_auth_plugin,
    'websockify_auth_source'         => $websockify_auth_source,
    'websockify_token_plugin'        => $websockify_token_plugin,
    'websockify_token_source'        => $websockify_token_source,
    'websockify_port'                => $websockify_port,
    'websockify_webroot'             => $websockify_webroot,
    'websockify_prefer_ipv6'         => $websockify_prefer_ipv6,
    'websockify_use_ssl'             => $websockify_use_ssl,
    'websockify_use_ssl_only'        => $websockify_use_ssl_only,
    'websockify_ssl_ca'              => $websockify_ssl_ca,
    'websockify_ssl_cert'            => $websockify_ssl_cert,
    'websockify_ssl_key'             => $websockify_ssl_key,
  }

  if $manage_service {
    systemd::unit_file { $websockify_service_name:
      ensure  => 'present',
      enable  => $websockify_service_enable,
      active  => $active,
      content => epp('vnc/usr/lib/systemd/system/websockify.service.epp', $template_params),
    }

    if $websockify_use_ssl {
      Systemd::Unit_file[$websockify_service_name] {
        subscribe => File[$websockify_ssl_cert, $websockify_ssl_key, $websockify_ssl_ca],
      }
    }
  }
}
