
# @summary Class for managing the Apache Web Role
#
# @param https Whether to enable HTTPS. Defaults to false.
#
# @param http Whether to enable HTTP. Defaults to true.
#
# @param manage_haproxy Whether to manage HAProxy. Defaults to false.
#
# @param ciphers The ciphers to use for SSL. Defaults to 'default'.
#
# @param modules The list of Apache modules to enable. Defaults to [].
#
# @param domains The list of domains to manage. Defaults to [].
#
# @param vhosts The virtual hosts configuration. Defaults to {}.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups connection https, http, manage_haproxy
#
# @groups security ciphers
#
# @groups configuration modules, domains, vhosts, encrypt_params
#
class role::web::apache (
  Boolean                     $https          = false,
  Boolean                     $http           = true,
  Boolean                     $manage_haproxy = false,
  Enum['default', 'insecure'] $ciphers        = 'default',
  Array                       $modules        = [],

  Eit_types::Web::Apache::Vhosts     $vhosts  = {},
  Array[Eit_types::Monitor::Domains] $domains = [],

  Eit_types::Encrypt::Params $encrypt_params       = [
    'vhosts.*.ssl_key',
    'vhosts.*.ssl_cert',
  ]
) inherits role::web {
  if $manage_haproxy {
    contain role::web::haproxy
  }

  confine(!$https, !$http, size($vhosts) == 0, 'Need https or http to be true or else you need to define vhosts')

  $vhosts.each | $vhost_name, $params | {
    confine(
      $params['ssl'],
      !($params['ssl_key'] and $params['ssl_cert']),
      "if ${vhost_name} virtualhost SSL is enabled, ssl_key and ssl_cert is required"
    )
  }

  contain profile::web::apache
}
