# Apache vhosts
type Eit_types::Web::Apache::Vhost_options = Struct[{
  ssl             => Optional[Boolean],
  ssl_cert        => Optional[String],
  ssl_key         => Optional[String],
  docroot         => Variant[Stdlib::Unixpath, Boolean],
  domains         => Optional[Array[Eit_types::Monitor::Domains]],
  port            => Optional[Stdlib::Port],
  redirect_dest   => Optional[Array[String]],
  redirect_status => Optional[Array[String]],
  serveraliases   => Optional[Array],
  directories     => Optional[Array[Hash]],
  aliases         => Optional[Array[Hash]],
  proxy_pass      => Optional[Array[Hash]],
}]
