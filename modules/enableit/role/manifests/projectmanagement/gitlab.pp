
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
# @param puma_worker_memory_mb Memory allocated for each Puma worker, in megabytes. Defaults to 1024.
#
# @param backup Whether to enable backups. Defaults to true.
#
# @param ssl_cert Optional SSL certificate for the GitLab instance. Defaults to undef.
#
# @param ssl_key Optional SSL key for the GitLab instance. Defaults to undef.
#
# @param package_version Optional package version for managing upgrades or migrations. Defaults to undef.
#
# @param enable_pages Whether to enable GitLab Pages. Defaults to false.
#
# @param monitoring_whitelist Optional list of allowed IP CIDRs for monitoring. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups domain domain.
#
# @groups notification email_enabled, email_display_name.
#
# @groups ssl ssl_cert, ssl_key.
#
# @groups backup backup.
#
# @groups registry registry.
#
# @groups mattermost mattermost.
#
# @groups monitoring prometheus, monitoring_whitelist.
#
# @groups performance puma_worker_memory_mb.
#
# @groups security terminate_https, redirect_http_to_https
#
# @groups git_config gitlab_rails, git_config
#
# @groups others time_zone, puma_bug, default_theme, package_version, encrypt_params, enable_pages
#
# @encrypt_params  ssl_cert, ssl_key
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
  Eit_types::MegaBytes                 $puma_worker_memory_mb    = 1024,
  Boolean                              $backup                   = true,
  Optional[String]                     $ssl_cert                 = undef,
  Optional[String]                     $ssl_key                  = undef,
  Optional[Eit_types::Package_version] $package_version          = undef,
  Boolean                              $enable_pages             = false,
  Optional[Array[Eit_types::IPCIDR]]   $monitoring_whitelist     = undef,
  Eit_types::Encrypt::Params $encrypt_params       = [
    'ssl_cert',
    'ssl_key',
  ]
) inherits ::role::projectmanagement {

  # contained before the confines below, which read their parameters
  contain role::projectmanagement::gitlab::backup
  contain role::projectmanagement::gitlab::registry
  contain role::projectmanagement::gitlab::mattermost
  contain role::projectmanagement::gitlab::enable_pages
  contain role::projectmanagement::gitlab::prometheus

  confine($facts['os']['family'] != 'Debian',
          'Only Debian-based distributions are supported')
  # Fail, if terminate_https is true and no ssl_cert and no ssl_key params are passed
  confine($terminate_https,
    (!$ssl_cert or !$ssl_key),
    '`ssl_cert` and `ssl_key` is mandatory if you want HTTPS to be enabled on gitlab server')
  #Fail if backups is set to true and no publick keys are set
  confine($backup,
    ($role::projectmanagement::gitlab::backup::public_keys.empty),
    '`public_keys` is mandatory if backup is set to true')
  # If registry is enabled and terminate_https is true, we need registry_ssl_cert
  # and registry_ssl_key to be defined.
  # Reason: if we have reverse proxy infront of gitlab, we can configure registry without ssl
  # https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl
  confine($registry,
    $terminate_https,
    (!$role::projectmanagement::gitlab::registry::ssl_cert or !$role::projectmanagement::gitlab::registry::ssl_key),
    '`registry_ssl_cert` and `registry_ssl_key` is mandatory if registry needs to be enabled on gitlab server')
  confine($mattermost,
    $terminate_https,
    (!$role::projectmanagement::gitlab::mattermost::ssl_cert or !$role::projectmanagement::gitlab::mattermost::ssl_key),
    '`mattermost_ssl_cert` and `mattermost_ssl_key` is mandatory if mattermost needs to be enabled on gitlab server')
  confine($enable_pages, !$role::projectmanagement::gitlab::enable_pages::domain,
          '`$pages_domain` must be configured to enable Gitlab Pages')
  confine($enable_pages, $role::projectmanagement::gitlab::enable_pages::domain.then |$_p| { $_p[$_p.size-$domain.size, $_p.size] == $domain },
          '`$pages_domain` must not be a subdomain of `$domain`.')

  if $::obmondo_classes[0] != 'role::projectmanagement::gitlab' {
    fail('class `role::projectmanagement::gitlab` MUST be the first element in classes array to add git to allowed_users via hiera.')
  }

  contain profile::projectmanagement::gitlab
}
