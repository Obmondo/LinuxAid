# @summary GitLab Pages settings, used when `enable_pages` is enabled
#
# @param domain The domain Pages is served on. Mandatory when Pages is enabled.
#
# @param ssl_cert The SSL certificate for Pages. Defaults to undef.
#
# @param ssl_key The SSL key for Pages. Defaults to undef.
#
# @groups enable_pages domain, ssl_cert, ssl_key
#
class role::projectmanagement::gitlab::enable_pages (
  Optional[Stdlib::Fqdn] $domain   = undef,
  Optional[String]       $ssl_cert = undef,
  Optional[String]       $ssl_key  = undef,
) {
}
