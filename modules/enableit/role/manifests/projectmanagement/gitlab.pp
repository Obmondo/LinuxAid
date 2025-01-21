#
# $redirect_http_to_https : only makes gitlab listen on port 80 (only relevant if $external_url start with https:// - which makes it not listen on port 80 normally). it actually won't redirect unless external_url IS set to https://
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
  #package_version variable used to manage upgrade or migration to new OS
  Optional[Eit_types::Package_version] $package_version          = undef,

  Boolean                $enable_pages = false,
  Optional[Stdlib::Fqdn] $pages_domain = undef,

  Optional[Array[Eit_types::IPCIDR]]                $monitoring_whitelist = undef,
  Optional[Eit_types::Gitlab::Prometheus_exporters] $prometheus_exporters = undef,

  Optional[Cron::Hour] $garbage_cleanup_job_hour = 4,

) inherits ::role::projectmanagement {

  confine($facts.dig('os', 'family') != 'Debian',
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

  if $facts['obmondo_classes'][0] != 'role::projectmanagement::gitlab' {
    fail('class `role::projectmanagement::gitlab` MUST be the first element in classes array to add git to allowed_users via hiera.')
  }

  contain profile::projectmanagement::gitlab
}
