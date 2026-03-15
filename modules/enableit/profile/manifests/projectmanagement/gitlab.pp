#
# $redirect_http_to_https : only makes gitlab listen on port 80 (only relevant if $external_url start with https:// - which makes it not listen on port 80 normally). it actually won't redirect unless external_url IS set to https://
#
class profile::projectmanagement::gitlab (
  Stdlib::Fqdn                         $domain                 = $role::projectmanagement::gitlab::domain,
  Eit_types::Timezone                  $time_zone              = $role::projectmanagement::gitlab::time_zone,
  Boolean                              $email_enabled          = $role::projectmanagement::gitlab::email_enabled,
  String                               $email_display_name     = $role::projectmanagement::gitlab::email_display_name,
  Boolean                              $registry               = $role::projectmanagement::gitlab::registry,
  Boolean                              $puma_bug               = $role::projectmanagement::gitlab::puma_bug,
  Boolean                              $mattermost             = $role::projectmanagement::gitlab::mattermost,
  Boolean                              $prometheus             = $role::projectmanagement::gitlab::prometheus,
  Eit_types::Gitlab::Theme             $default_theme          = $role::projectmanagement::gitlab::default_theme,
  Boolean                              $terminate_https        = $role::projectmanagement::gitlab::terminate_https,
  Boolean                              $redirect_http_to_https = $role::projectmanagement::gitlab::redirect_http_to_https,
  Hash                                 $gitlab_rails           = $role::projectmanagement::gitlab::gitlab_rails,
  Hash                                 $git_config             = $role::projectmanagement::gitlab::git_config,
  Hash                                 $mattermost_config      = $role::projectmanagement::gitlab::mattermost_config,
  Boolean                              $backup                 = $role::projectmanagement::gitlab::backup,
  Integer[0,23]                        $backup_cron_hour       = $role::projectmanagement::gitlab::backup_cron_hour,
  Optional[Stdlib::Absolutepath]       $backup_path            = $role::projectmanagement::gitlab::backup_path,
  Integer[1,default]                   $backup_keep_days       = $role::projectmanagement::gitlab::backup_keep_days,
  Optional[String]                     $ssl_cert               = $role::projectmanagement::gitlab::ssl_cert,
  Optional[String]                     $ssl_key                = $role::projectmanagement::gitlab::ssl_key,
  Optional[String]                     $registry_ssl_cert      = $role::projectmanagement::gitlab::registry_ssl_cert,
  Optional[String]                     $registry_ssl_key       = $role::projectmanagement::gitlab::registry_ssl_key,
  Stdlib::Fqdn                         $registry_domain        = $role::projectmanagement::gitlab::registry_domain,
  Optional[Array[Stdlib::IP::Address]] $trusted_proxies        = $role::projectmanagement::gitlab::trusted_proxies,
  Optional[String]                     $mattermost_ssl_cert    = $role::projectmanagement::gitlab::mattermost_ssl_cert,
  Optional[String]                     $mattermost_ssl_key     = $role::projectmanagement::gitlab::mattermost_ssl_key,
  Stdlib::Fqdn                         $mattermost_domain      = $role::projectmanagement::gitlab::mattermost_domain,
  Array[String]                        $public_keys            = $role::projectmanagement::gitlab::public_keys,
  Eit_types::User                      $backupcron_user        = $role::projectmanagement::gitlab::backupcron_user,
  Optional[Eit_types::Package_version] $package_version        = $role::projectmanagement::gitlab::package_version,
  Eit_types::MegaBytes                 $puma_worker_memory_mb  = $role::projectmanagement::gitlab::puma_worker_memory_mb,
  Boolean                              $enable_pages           = $role::projectmanagement::gitlab::enable_pages,
  Optional[Stdlib::Fqdn]               $pages_domain           = $role::projectmanagement::gitlab::pages_domain,
  Optional[String]                     $pages_ssl_cert         = $role::projectmanagement::gitlab::pages_ssl_cert,
  Optional[String]                     $pages_ssl_key          = $role::projectmanagement::gitlab::pages_ssl_key,
  Eit_types::Certname                  $host                   = $trusted['certname'],
  Optional[Array[Eit_types::IPCIDR]]                $monitoring_whitelist = $role::projectmanagement::gitlab::monitoring_whitelist,
  Optional[Eit_types::Gitlab::Prometheus_exporters] $prometheus_exporters = $role::projectmanagement::gitlab::prometheus_exporters,

  Cron::Hour $garbage_cleanup_job_hour = $role::projectmanagement::gitlab::garbage_cleanup_job_hour,

) inherits profile {

  contain monitor::system::service::gitlab

  if $ssl_cert {
    $ssl_cert_filepath = "/etc/ssl/private/${domain}/combined.pem"
    $ssl_key_filepath = "/etc/ssl/private/${domain}/privkey.pem"
    $job_name = 'probe_domains_blackbox'
    $collect_dir = '/etc/prometheus/file_sd_config.d'

    @@prometheus::scrape_job { "blackbox_domain_${trusted['certname']}_${domain}" :
      job_name    => $job_name,
      tag         => [
        $trusted['certname'],
        $::obmondo['customer_id'], #lint:ignore:top_scope_facts
      ],
      targets     => ["${domain}/users/sign_in"],
      noop        => false,
      labels      => { 'certname' => $trusted['certname'] },
      collect_dir => $collect_dir,
    }

    monitor::domains { $domain:
      enable => true,
    }

    File <| title == "${collect_dir}/${job_name}_blackbox_domain_${trusted['certname']}_${domain}.yaml" |> {
      ensure => absent
    }

    file { "/etc/ssl/private/${domain}":
      ensure => directory,
      owner  => 'gitlab-www',
      mode   => '0640',
    }

    file { $ssl_key_filepath:
      ensure  => file,
      content => $ssl_key.node_encrypt::secret,
      owner   => 'gitlab-www',
      mode    => '0640',
      require => File["/etc/ssl/private/${domain}"],
    }

    file { $ssl_cert_filepath:
      ensure  => file,
      content => $ssl_cert.node_encrypt::secret,
      owner   => 'gitlab-www',
      mode    => '0640',
      require => File["/etc/ssl/private/${domain}"],
    }
  }

  package { 'obmondo-gitlab-update-check-collector':
    ensure => 'latest',
  }

  $textfile_directory = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)

  file { "${textfile_directory}/gitlab.prom" :
    ensure  => 'file',
    require => Package['obmondo-gitlab-update-check-collector'],
  }

  $_gitlab_update_timer = @("EOT"/)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Check for GitLab updates daily
    Requires=gitlab-update-check.service

    [Timer]
    OnCalendar=*-*-* 00:00:00
    Unit=gitlab-update-check.service

    [Install]
    WantedBy=timers.target
    | EOT

  $_gitlab_update_service = @("EOT"/)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Check for GitLab updates
    Wants=gitlab-update-check.timer

    [Service]
    Type=oneshot
    ExecStart=sh -c '/opt/obmondo/bin/check_gitlab_update > ${textfile_directory}/gitlab.prom'

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::timer { 'gitlab-update-check.timer':
    ensure          => present,
    active          => true,
    enable          => true,
    timer_content   => $_gitlab_update_timer,
    service_content => $_gitlab_update_service,
    require         => [
      Package['obmondo-gitlab-update-check-collector'],
      File["${textfile_directory}/gitlab.prom"],
    ],
  }

  ## The puma_worker is using high cpu to to restart th puma_worker need to restart the gitlab service
  $_puma_bug_timer = @("EOT"/)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Puma worker using high cpu so restarting the gitlab service
    Requires=gitlab-puma-bug.service

    [Timer]
    OnCalendar=Tue *-*-* 05:00:00
    Unit=gitlab-puma-bug.service

    [Install]
    WantedBy=timers.target
    | EOT

  $_puma_bug_service = @("EOT"/)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Puma worker using high cpu so restarting the gitlab service
    Wants=gitlab-puma-bug.timer

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/gitlab-ctl restart

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::timer { 'gitlab-puma-bug.timer':
    ensure          => present,
    active          => true,
    enable          => true,
    timer_content   => $_puma_bug_timer,
    service_content => $_puma_bug_service,
  }

  $bind_ports = [
    if $terminate_https { 443 },
    80,
  ].delete_undef_values

  firewall_multi { '200 allow access to Gitlab':
    proto => 'tcp',
    dport => $bind_ports,
    jump  => 'accept',
  }

  $_themes = ['graphite', 'charcoal', 'green', 'black', 'violet', 'blue']
  $_theme = Hash(flatten(zip($_themes, range(1,size($_themes)))))[$default_theme]

  $_protocol = if $redirect_http_to_https { 'https' } else { 'http' }

  # https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl
  if $terminate_https {
    $_nginx_defaults = {
      ssl_ciphers             => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256', #lint:ignore:140chars
      ssl_protocols           => 'TLSv1.2',
      ssl_certificate         => $ssl_cert_filepath,
      ssl_certificate_key     => $ssl_key_filepath,
    }
  } else {
    $_nginx_defaults = {
      listen_port => 80,
    }
  }

  $_nginx = {
    redirect_http_to_https    => $redirect_http_to_https,
    listen_https              => $terminate_https,
    real_ip_header            => 'X-Forwarded-For',
    real_ip_recursive         => 'on',
    real_ip_trusted_addresses => $trusted_proxies,
  } + $_nginx_defaults

if $registry and ! $prometheus_exporters.dig('registry') =~ Eit_types::Listen {
    fail("${registry} and ${prometheus_exporters.dig('registry')}")
  }

  # https://github.com/gitlabhq/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template#L723
  $enable_registry = if $registry and ! $prometheus_exporters.dig('registry') =~ Eit_types::Listen {
    {
      'enable' => $registry,
    }
  }

  $registry_nginx = if $registry {

    # If we have reverse proxy infront of gitlab, then we dont need SSL
    # https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl
    $registry_external_url = if $terminate_https {
      $_container_registry_port = 4567

      # Allow registry access from allowed IP ranges
      firewall_multi { '200 allow access to Gitlab Docker registry':
        proto => 'tcp',
        dport => $_container_registry_port,
        jump  => 'accept',
      }

      "https://${registry_domain}:${_container_registry_port}"
    } else {
      "https://${registry_domain}"
    }

    package { 'obmondo-gitlab-registry-gc':
      ensure  => latest,
      require => Class[gitlab],
    }

    cron::daily { 'registry_garbage_collector':
      ensure  => 'present',
      command => 'chronic /opt/obmondo/bin/garbage_collect_registry',
      minute  => fqdn_rand(60),
      hour    => $garbage_cleanup_job_hour,
      user    => 'root',
      require => Package['obmondo-gitlab-registry-gc'],
    }

    $registry_cert_filepath = "/etc/ssl/private/${registry_domain}/cert.pem"
    $registry_key_filepath = "/etc/ssl/private/${registry_domain}/privkey.pem"

    [
      if $registry_domain != $domain and $terminate_https {
        file { "/etc/ssl/private/${registry_domain}":
          ensure => directory,
          owner  => 'gitlab-www',
          mode   => '0640',
        }

        file { $registry_key_filepath:
          ensure  => file,
          content => $registry_ssl_key.node_encrypt::secret,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

        file { $registry_cert_filepath:
          ensure  => file,
          content => $registry_ssl_cert.node_encrypt::secret,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

        Hash([
          # Registry only support HTTPS, HTTP is supported but not recommended
          # https://docs.docker.com/registry/insecure/
          # But if we have reverse proxy infront, then we dont need SSL
          # https://docs.gitlab.com/omnibus/settings/nginx.html#supporting-proxied-ssl
          ['ssl_certificate', $registry_cert_filepath],
          ['ssl_certificate_key', $registry_key_filepath],
        ])
      },
      $_nginx,
    ].merge_hashes
  }

  $pages_nginx = if $enable_pages {
    $pages_external_url = "https://${pages_domain}"
    $pages_cert_filepath = "/etc/ssl/private/${pages_domain}/cert.pem"
    $pages_key_filepath = "/etc/ssl/private/${pages_domain}/privkey.pem"

    [
      if $pages_domain != $domain and $terminate_https {
        file { $pages_key_filepath:
          ensure  => file,
          content => $pages_ssl_key,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

        file { $pages_cert_filepath:
          ensure  => file,
          content => $pages_ssl_cert,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

        Hash([
          ['ssl_certificate', $pages_cert_filepath],
          ['ssl_certificate_key', $pages_key_filepath],
        ])
      },
      $_nginx,
    ].merge_hashes
  }

  $mattermost_nginx = [
    if $mattermost {
      $mattermost_external_url = "https://${mattermost_domain}"

      if $mattermost_domain != $domain and $terminate_https {
        $_mattermost_cert_filepath = "/etc/ssl/private/${mattermost_domain}/cert.pem"
        $_mattermost_key_filepath = "/etc/ssl/private/${mattermost_domain}/privkey.pem"
        file { $_mattermost_key_filepath:
          ensure  => file,
          content => $mattermost_ssl_key.node_encrypt::secret,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

        file { $_mattermost_cert_filepath:
          ensure  => file,
          content => $mattermost_ssl_cert.node_encrypt::secret,
          owner   => 'gitlab-www',
          mode    => '0640',
        }

      }

      Hash([
        ['ssl_certificate', $_mattermost_cert_filepath],
        ['ssl_certificate_key', $_mattermost_key_filepath],
      ])
    },
    $_nginx
  ].merge_hashes

  $_backup_path = [$backup_path, '/var/opt/gitlab/backups'].first

  $_exporters = $prometheus_exporters.lest || {
    # This is a bit awkward, but we need to ensure that we only include the
    # parameter once. If we enable the exporter we can't include it directly in
    # the call to the `gitlab` class, so we'll just include it here instead.
    {
      registry => $enable_registry,
      puma     => {
        'per_worker_max_memory_mb' => $puma_worker_memory_mb,
      },
    }
  }.reduce({}) |$acc, $_arg| {
    [$_exporter, $_listen_address] = $_arg

    [$_listen_host, $_listen_port] = $_listen_address ? {
      Integer => ['127.254.254.254', $_listen_address],
      String  => $_listen_address.split(':').then |$_split| {
        if $_split.size != 2 {
          fail("${_exporter}: ${_listen_address} could not be split in two!")
        }
        $_split
      },
      Boolean => [undef, undef],
      default => fail("${_exporter}: unsupported type of ${_listen_address} (${_listen_address.type})"),
    }

    if $monitoring_whitelist and $prometheus {
      firewall_multi { "210 allow access to ${_exporter} metrics":
        proto  => 'tcp',
        source => $monitoring_whitelist,
        dport  => $_listen_port,
        jump   => 'accept',
      }
    }

    if $prometheus {
      prometheus::scrape_job { "gitlab_${_exporter}_exporter" :
        job_name    => "gitlab-${_exporter}",
        tag         => $::trusted['certname'],
        targets     => [ "${host}:${_listen_port}" ],
        labels      => { 'alias' => $::trusted['certname'] },
        collect_dir => '/etc/prometheus/file_sd_config.d',
      }
    }

    $acc + case $_exporter {
      'gitlab': {
        {
          'gitlab_exporter' => {
            'enable'         => $prometheus,
            'listen_address' => $_listen_host,
            'listen_port'    => $_listen_port,
          },
        }
      }
      'puma': {
        {
          'puma' => {
            'per_worker_max_memory_mb' => $puma_worker_memory_mb,
            'exporter_enabled'         => $prometheus,
            'exporter_address'         => $_listen_host,
            'exporter_port'            => $_listen_port,
          },
        }
      }
      'postgres': {
        {
          'postgres_exporter' => {
            'enable'         => $prometheus,
            'listen_address' => "${_listen_host}:${_listen_port}",
          },
        }
      }
      'registry': {
        if $registry {
          {
            'registry' => {
              'enable'     => true,
              'debug_addr' => "${_listen_host}:${_listen_port}",
            },
          }
        }
      }
      # can only be used if pgbouncer role is enabled, see
      # https://docs.gitlab.com/ee/administration/monitoring/prometheus/pgbouncer_exporter.html
      #
      # 'pgbouncer': {
      #   {
      #     'pgbouncer_exporter' => {
      #       'enable'         => true,
      #       'listen_address' => "${_listen_host}:${_listen_port}",
      #     }
      #   }
      # }
      'redis': {
        {
          'redis_exporter' => {
            'enable'         => $prometheus,
            'listen_address' => "${_listen_host}:${_listen_port}",
          }
        }
      }

      default: {
        fail("unsupported exporter ${_exporter}")
      }
    }
  }

  class { 'gitlab':
    external_url                 => "${_protocol}://${domain}",
    gitlab_rails                 => [
      {
        time_zone                 => $time_zone,
        gitlab_email_enabled      => $email_enabled,
        gitlab_default_theme      => $_theme,
        gitlab_email_display_name => $email_display_name,
        backup_path               => $_backup_path,
      },
      $gitlab_rails,
      if $monitoring_whitelist {
        {
          'monitoring_whitelist' => $monitoring_whitelist,
        }
      },
    ].merge_hashes,
    sidekiq                      => {
      shutdown_timeout => 5,
    },
    git                          => $git_config,
    nginx                        => $_nginx,
    backup_cron_enable           => $backup,
    backup_cron_hour             => $backup_cron_hour,
    manage_package               => true,
    package_ensure               => $package_version,
    registry_external_url        => if $registry { $registry_external_url },
    registry_nginx               => if $registry { $registry_nginx },
    mattermost                   => {
      'enable'                      => $mattermost,
      'service_enable_custom_emoji' => true,
    } + $mattermost_config,
    mattermost_external_url      => if $mattermost { $mattermost_external_url },
    mattermost_nginx             => if $mattermost { $mattermost_nginx },
    pages_external_url           => if $enable_pages { $pages_external_url },
    pages_nginx                  => if $enable_pages { $pages_nginx },
    prometheus_monitoring_enable => $prometheus,
    prometheus                   => if $prometheus and $prometheus_exporters != undef {
      # we need this enabled if the gitlab exporter is enabled
      { enable => !!($prometheus_exporters.dig('gitlab')), }
    },
    *                            => $_exporters,
  }

  if $backup {
    $gpg_keys = $public_keys.map |$keys| {
      $keys
    }
    package { 'obmondo-gitlab-backup-secrets' :
      ensure  => present,
      require => Class[gitlab],
    }

    file { '/opt/obmondo/gitlab_backup' :
      ensure => directory,
      mode   => '0700',
      owner  => $backupcron_user,
    }
    file { '/opt/obmondo/gitlab_backup/public_keys.asc':
      ensure  => 'file',
      content => $gpg_keys.join("\n"),
      owner   => $backupcron_user,
    }
    cron { 'gitlab backup secrets':
      command     => "/opt/obmondo/bin/gitlab_backup_secrets ${_backup_path}",
      user        => $backupcron_user,
      hour        => lookup('gitlab::backup_cron_hour', Eit_types::TimeHour, undef, 2),
      minute      => lookup('gitlab::backup_cron_minute', Eit_types::TimeMinute, undef, 0),
      environment => [
        'PATH=/bin:/usr/bin',
      ],
      require     => Package['obmondo-gitlab-backup-secrets'],
    }

    cron { 'remove old gitlab backups':
      command     => "find '${_backup_path}' -maxdepth 2 \\( -name '*.tar' -o -name '*.gpg' -o -name '*.gz' \\) -mtime +${backup_keep_days} -delete", #lint:ignore:140chars
      user        => $backupcron_user,
      hour        => lookup('gitlab::backup_cron_hour', Eit_types::TimeHour, undef, 3),
      minute      => lookup('gitlab::backup_cron_minute', Eit_types::TimeMinute, undef, 0),
      environment => [
        'PATH=/bin:/usr/bin',
      ],
    }

    $gitlab_psql_user = 'gitlab-psql'

    user { $gitlab_psql_user:
      groups => 'git',
    }

    # Using defined function since /backup/dkcphgitlab02 is already getting mounted from class common:storage::mount.
    if (!defined(File[$_backup_path])) {
      file { $_backup_path:
        ensure => ensure_dir($mattermost),
        mode   => '0750',
        owner  => 'git',
        group  => 'git',
      }
    }

    file { "${_backup_path}/mattermost":
      ensure => ensure_dir($mattermost),
      owner  => $gitlab_psql_user,
      group  => $gitlab_psql_user,
    }

    # Calculate DB backup time based on GitLab offsets
    $_db_hour   = 1 + lookup('gitlab::backup_cron_hour', Eit_types::TimeHour, undef, 3)
    $_db_minute = 1 + lookup('gitlab::backup_cron_minute', Eit_types::TimeMinute, undef, 0)

    $_mm_db_timer = @("EOT"/)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Mattermost DB backup timer
      Requires=mattermost-db-backup.service

      [Timer]
      OnCalendar=*-*-* ${_db_hour}:${_db_minute}:00
      Unit=mattermost-db-backup.service

      [Install]
      WantedBy=timers.target
      | EOT

    $_mm_db_service = @("EOT"/)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Mattermost DB backup service
      Wants=mattermost-db-backup.timer

      [Service]
      Type=simple
      User=${gitlab_psql_user}
      Group=${gitlab_psql_user}
      ExecStart=sh -c '/opt/gitlab/embedded/bin/pg_dump -h /var/opt/gitlab/postgresql mattermost_production | gzip > ${_backup_path}/mattermost/mattermost_dbdump_$(date --rfc-3339=date).sql.gz'

      [Install]
      WantedBy=multi-user.target
      | EOT

    systemd::timer { 'mattermost-db-backup.timer':
      ensure          => ensure_present($mattermost),
      active          => $mattermost,
      enable          => $mattermost,
      timer_content   => $_mm_db_timer,
      service_content => $_mm_db_service,
    }

    # Calculate Data backup time based on GitLab offsets
    $_data_hour   = 2 + lookup('gitlab::backup_cron_hour', Eit_types::TimeHour, undef, 3)
    $_data_minute = 2 + lookup('gitlab::backup_cron_minute', Eit_types::TimeMinute, undef, 0)

    $_mm_data_timer = @("EOT"/)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Mattermost data backup timer
      Requires=mattermost-data-backup.service

      [Timer]
      OnCalendar=*-*-* ${_data_hour}:${_data_minute}:00
      Unit=mattermost-data-backup.service

      [Install]
      WantedBy=timers.target
      | EOT

    $_mm_data_service = @("EOT"/)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Mattermost data backup service
      Wants=mattermost-data-backup.timer

      [Service]
      Type=simple
      User=${backupcron_user}
      Group=${backupcron_user}
      ExecStart=sh -c '/usr/bin/tar -zcvf ${_backup_path}/mattermost_data_$(date --rfc-3339=date).gz -C /var/opt/gitlab/mattermost data config.json'

      [Install]
      WantedBy=multi-user.target
      | EOT

    systemd::timer { 'mattermost-data-backup.timer':
      ensure          => ensure_present($mattermost),
      active          => $mattermost,
      enable          => $mattermost,
      timer_content   => $_mm_data_timer,
      service_content => $_mm_data_service,
    }
  }
}
