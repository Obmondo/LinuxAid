
# @summary Class for managing the GitLab project management role
#
# @param domain The domain name for the GitLab instance.
#
# @param email_enabled Whether to enable email notifications.
#
# @param email_display_name The display name for email notifications.
#
# @param time_zone The timezone for the GitLab instance. Defaults to the system's timezone.
#
# @param registry Whether to enable the container registry. Defaults to true.
#
# @param prometheus Whether to enable Prometheus integration. Defaults to true.
#
# @param puma_bug Whether to apply the Puma bug workaround. Defaults to false.
#
# @param mattermost Whether to enable Mattermost integration. Defaults to false.
#
# @param default_theme The default theme for GitLab. Defaults to 'black'.
#
# @param terminate_https Whether to terminate HTTPS on the GitLab server. Defaults to false.
#
# @param redirect_http_to_https Whether to redirect HTTP traffic to HTTPS. Defaults to true.
#
# @param gitlab_rails Hash of additional GitLab Rails configuration options. Defaults to an empty hash.
#
# @param git_config Hash of Git configuration options. Defaults to an empty hash.
#
# @param mattermost_config Hash of Mattermost configuration options. Defaults to an empty hash.
#
# @param puma_worker_memory_mb Memory allocated for each Puma worker, in megabytes. Defaults to 1024.
#
# @param backup Whether to enable backups. Defaults to true.
#
# @param backup_cron_hour The hour of the day to run backups, in 24-hour format. Defaults to 2.
#
# @param backup_path Optional path to store backups. Defaults to undef.
#
# @param backup_keep_days The number of days to keep backups. Defaults to 7.
#
# @param ssl_cert Optional SSL certificate for the GitLab instance. Defaults to undef.
#
# @param ssl_key Optional SSL key for the GitLab instance. Defaults to undef.
#
# @param registry_ssl_cert Optional SSL certificate for the container registry. Defaults to the value of ssl_cert.
#
# @param registry_ssl_key Optional SSL key for the container registry. Defaults to the value of ssl_key.
#
# @param registry_domain The domain for the container registry.
#
# @param trusted_proxies List of trusted proxies for the GitLab instance. Defaults to an empty array.
#
# @param mattermost_ssl_cert Optional SSL certificate for Mattermost. Defaults to the value of ssl_cert.
#
# @param mattermost_ssl_key Optional SSL key for Mattermost. Defaults to the value of ssl_key.
#
# @param pages_ssl_cert Optional SSL certificate for GitLab Pages. Defaults to undef.
#
# @param pages_ssl_key Optional SSL key for GitLab Pages. Defaults to undef.
#
# @param mattermost_domain The domain for the Mattermost instance.
#
# @param public_keys List of public keys for backup purposes. Defaults to an empty array.
#
# @param backupcron_user The user account to run the backup cron job. Defaults to 'root'.
#
# @param package_version Optional package version for managing upgrades or migrations. Defaults to undef.
#
# @param enable_pages Whether to enable GitLab Pages. Defaults to false.
#
# @param pages_domain Optional domain for GitLab Pages. Defaults to undef.
#
# @param monitoring_whitelist Optional list of allowed IP CIDRs for monitoring. Defaults to undef.
#
# @param prometheus_exporters Optional custom Prometheus exporters. Defaults to undef.
#
# @param garbage_cleanup_job_hour The hour of the day to run garbage cleanup jobs. Defaults to 4.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class role::projectmanagement::gitlab (
  Stdlib::Fqdn                         $domain,
  Boolean                              $email_enabled,
  String                               $email_display_name,
  Eit_types::Timezone                  $time_zone                = $common::system::time::timezone,
  Boolean                              $registry                 = true,
  Boolean                              $prometheus               = true,
  Boolean                              $puma_bug                 = false,
  Boolean                              $mattermost               = false,
  Eit_types::Gitlab::Theme             $default_theme            = 'black',
  Boolean                              $terminate_https          = false,
  Boolean                              $redirect_http_to_https   = true,
  Hash                                 $gitlab_rails             = {},
  Hash                                 $git_config               = {},
  Hash                                 $mattermost_config        = {},
  Eit_types::MegaBytes                 $puma_worker_memory_mb    = 1024,
  Boolean                              $backup                   = true,
  Integer[0,23]                        $backup_cron_hour         = 2,
  Optional[Stdlib::Absolutepath]       $backup_path              = undef,
  Integer[1,default]                   $backup_keep_days         = 7,
  Optional[String]                     $ssl_cert                 = undef,
  Optional[String]                     $ssl_key                  = undef,
  Optional[String]                     $registry_ssl_cert        = $ssl_cert,
  Optional[String]                     $registry_ssl_key         = $ssl_key,
  Stdlib::Fqdn                         $registry_domain          = $domain,
  Optional[Array[Stdlib::IP::Address]] $trusted_proxies          = [],
  Optional[String]                     $mattermost_ssl_cert      = $ssl_cert,
  Optional[String]                     $mattermost_ssl_key       = $ssl_key,
  Optional[String]                     $pages_ssl_cert           = undef,
  Optional[String]                     $pages_ssl_key            = undef,
  Stdlib::Fqdn                         $mattermost_domain        = $domain,
  Array[String]                        $public_keys              = [],
  Eit_types::User                      $backupcron_user          = 'root',
  Optional[Eit_types::Package_version] $package_version          = undef,
  Boolean                              $enable_pages             = false,
  Optional[Stdlib::Fqdn]               $pages_domain             = undef,
  Optional[Array[Eit_types::IPCIDR]]   $monitoring_whitelist     = undef,
  Optional[Eit_types::Gitlab::Prometheus_exporters] $prometheus_exporters = undef,
  Optional[Cron::Hour]                 $garbage_cleanup_job_hour  = 4,

  Eit_types::Encrypt::Params $encrypt_params       = [
    'ssl_cert',
    'ssl_key',
    'registry_ssl_cert',
    'registry_ssl_key',
    'mattermost_ssl_cert',
    'mattermost_ssl_key',
  ]
) inherits ::role::projectmanagement {

  confine($facts['os']['family'] != 'Debian',
          'Only Debian-based distributions are supported')
  # Fail, if terminate_https is true and no ssl_cert and no ssl_key params are passed
  confine($terminate_https,
    (!$ssl_cert or !$ssl_key),
    '`ssl_cert` and `ssl_key` is mandatory if you want HTTPS to be enabled on gitlab server')
  #Fail if backups is set to true and no publick keys are set
  confine($backup,
    ($public_keys.empty),
    '`public_keys` is mandatory if backup is set to true')
  # If registry is enabled and terminate_https is true, we need registry_ssl_cert
  # and registry_ssl_key to be defined.
  # Reason: if we have reverse proxy infront of gitlab, we can configure registry without ssl
  # https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl
  confine($registry,
    $terminate_https,
    (!$registry_ssl_cert or !$registry_ssl_key),
    '`registry_ssl_cert` and `registry_ssl_key` is mandatory if registry needs to be enabled on gitlab server')
  confine($mattermost,
    $terminate_https,
    (!$mattermost_ssl_cert or !$mattermost_ssl_key),
    '`mattermost_ssl_cert` and `mattermost_ssl_key` is mandatory if mattermost needs to be enabled on gitlab server')
  confine($enable_pages, !$pages_domain,
          '`$pages_domain` must be configured to enable Gitlab Pages')
  confine($enable_pages, $pages_domain.then |$_| { $pages_domain[$pages_domain.size-$domain.size, $pages_domain.size] == $domain },
          '`$pages_domain` must not be a subdomain of `$domain`.')

  if $::obmondo_classes[0] != 'role::projectmanagement::gitlab' {
    fail('class `role::projectmanagement::gitlab` MUST be the first element in classes array to add git to allowed_users via hiera.')
  }

  contain profile::projectmanagement::gitlab
}
