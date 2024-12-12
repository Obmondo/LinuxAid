# Apache Web Role
class role::web::apache (
  Boolean                     $https          = false,
  Boolean                     $http           = true,
  Boolean                     $manage_haproxy = false,
  Enum['default', 'insecure'] $ciphers        = 'default',
  Array                       $modules        = [],

  Array[Eit_types::Monitor::Domains] $domains = [],

  Hash[String,Struct[{
    ssl                      => Optional[Boolean],
    ssl_cert                 => Optional[String],
    ssl_key                  => Optional[String],
    docroot                  => Variant[Stdlib::Unixpath, Boolean],
    domains                  => Optional[Array[Eit_types::Monitor::Domains]],
    port                     => Optional[Stdlib::Port],
    redirect_dest            => Optional[Array[String]],
    redirect_status          => Optional[Array[String]],
    serveraliases            => Optional[Array],
    directories              => Optional[Array[Hash]],
    aliases                  => Optional[Array[Hash]],
    proxy_pass               => Optional[Array[Hash]],
  }]]                         $vhosts         = {},
) {

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

