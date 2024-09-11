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
