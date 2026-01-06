
# @summary Class for managing the Nginx web server role
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @param http Whether to enable HTTP. Defaults to true.
#
# @param manage_repo Whether to manage the repository. Defaults to false.
#
# @param cfg_prepend Hash of configuration options to prepend. Defaults to {}.
#
# @param http_cfg_prepend Hash of HTTP configuration options to prepend. Defaults to {}.
#
# @param modules Array of additional modules to include. Defaults to [].
#
# @param monitor_port The port to monitor. Defaults to 63080.
#
# @param extra_cfg_option Hash of additional configuration options. Defaults to {}.
#
# @param servers Hash of server configurations. Defaults to {}.
#
# @param $__blendable 
# Internal parameter for blendable role support. No default value.
#
# @param package_source The package source for Nginx. Defaults to 'nginx'.
#
# @groups network ssl, http, monitor_port
#
# @groups config manage_repo, cfg_prepend, http_cfg_prepend, extra_cfg_option, servers
#
# @groups enhancements modules, package_source
#
class role::web::nginx (
  Boolean                    $ssl              = false,
  Boolean                    $http             = true,
  Boolean                    $manage_repo      = false,
  Hash                       $cfg_prepend      = {},
  Hash                       $http_cfg_prepend = {},
  Array                      $modules          = [],
  Stdlib::Port               $monitor_port     = 63080,
  Hash                       $extra_cfg_option = {},
  Hash                       $servers          = {},
  Boolean                    $__blendable,
  Enum['nginx', 'passenger'] $package_source   = 'nginx',
) inherits ::role {

  include profile::web::nginx
}
