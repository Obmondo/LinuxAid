# @summary
#   Installs `mod_authn_dbd`.
# 
# @param authn_dbd_params
#   The params needed for the mod to function.
#   
# @param authn_dbd_dbdriver
#   Selects an apr_dbd driver by name.
#   
# @param authn_dbd_query
#   
# @param authn_dbd_min
#   Set the minimum number of connections per process.
#   
# @param authn_dbd_max
#   Set the maximum number of connections per process.
#   
# @param authn_dbd_keep
#   Set the maximum number of connections per process to be sustained.
#   
# @param authn_dbd_exptime
#   Set the time to keep idle connections alive when the number of 
#   connections specified in DBDKeep has been exceeded.
#   
# @param authn_dbd_alias
#   Sets an alias for `AuthnProvider.
#
# @see https://httpd.apache.org/docs/current/mod/mod_authn_dbd.html for additional documentation.
#
class apache::mod::authn_dbd (
  Optional[String] $authn_dbd_params,
  String $authn_dbd_dbdriver         = 'mysql',
  Optional[String] $authn_dbd_query  = undef,
  Integer $authn_dbd_min             = 4,
  Integer $authn_dbd_max             = 20,
  Integer $authn_dbd_keep            = 8,
  Integer $authn_dbd_exptime         = 300,
  Optional[String] $authn_dbd_alias  = undef,
) inherits apache::params {
  include apache
  include apache::mod::dbd
  ::apache::mod { 'authn_dbd': }

  if $authn_dbd_alias {
    include apache::mod::authn_core
  }

  $parameters = {
    'authn_dbd_dbdriver'  => $authn_dbd_dbdriver,
    'authn_dbd_params'    => $authn_dbd_params,
    'authn_dbd_min'       => $authn_dbd_min,
    'authn_dbd_max'       => $authn_dbd_max,
    'authn_dbd_keep'      => $authn_dbd_keep,
    'authn_dbd_exptime'   => $authn_dbd_exptime,
    'authn_dbd_alias'     => $authn_dbd_alias,
    'authn_dbd_query'     => $authn_dbd_query,
  }

  # Template uses
  # - All variables beginning with authn_dbd
  file { 'authn_dbd.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/authn_dbd.conf",
    mode    => $apache::file_mode,
    content => epp('apache/mod/authn_dbd.conf.epp', $parameters),
    require => [Exec["mkdir ${apache::mod_dir}"],],
    before  => File[$apache::mod_dir],
    notify  => Class['Apache::Service'],
  }
}
