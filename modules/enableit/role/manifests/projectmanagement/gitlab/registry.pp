# @summary Container registry settings for GitLab, used when `registry` is enabled
#
# @param ssl_cert The SSL certificate for the registry. Defaults to the GitLab certificate.
#
# @param ssl_key The SSL key for the registry. Defaults to the GitLab key.
#
# @param domain The domain the registry is served on. Defaults to the GitLab domain.
#
# @param trusted_proxies The proxies the registry trusts. Defaults to an empty array.
#
# @param garbage_cleanup_job_hour The hour of day the registry garbage collection runs. Defaults to 4.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups registry ssl_cert, ssl_key, domain, trusted_proxies, garbage_cleanup_job_hour, encrypt_params
#
# @encrypt_params ssl_cert, ssl_key
#
class role::projectmanagement::gitlab::registry (
  Optional[String]                     $ssl_cert                 = $role::projectmanagement::gitlab::ssl_cert,
  Optional[String]                     $ssl_key                  = $role::projectmanagement::gitlab::ssl_key,
  Stdlib::Fqdn                         $domain                   = $role::projectmanagement::gitlab::domain,
  Optional[Array[Stdlib::IP::Address]] $trusted_proxies          = [],
  Optional[Cron::Hour]                 $garbage_cleanup_job_hour = 4,

  Eit_types::Encrypt::Params $encrypt_params = [
    'ssl_cert',
    'ssl_key',
  ]
) {
}
