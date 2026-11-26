# Mailcow Setup
class profile::mail::mailcow (
  Boolean                     $manage                   = $role::mail::mailcow::manage,
  Boolean                     $letsencrypt              = $role::mail::mailcow::letsencrypt,
  Eit_types::Mailcow::Version $version                  = $role::mail::mailcow::version,
  Stdlib::Unixpath            $backup_dir               = $role::mail::mailcow::backup_dir,
  String                      $dbroot                   = $role::mail::mailcow::dbroot,
  String                      $dbpass                   = $role::mail::mailcow::dbpass,
  String                      $redispass                = $role::mail::mailcow::redispass,
  Optional[Eit_types::Email]  $acme_contact             = $role::mail::mailcow::letsencrypt::acme_contact,
  Eit_types::Timezone         $timezone                 = $role::mail::mailcow::timezone,
  Optional[Hash]              $extra_settings           = $role::mail::mailcow::extra_settings,
  Stdlib::Fqdn                $domain                   = $role::mail::mailcow::domain,
  String                      $exporter_api_key         = $role::mail::mailcow::exporter_api_key,
  Optional[Boolean]           $skip_unbound_healthcheck = $role::mail::mailcow::skip_unbound_healthcheck,
) {
  $install_dir              = '/opt/mailcow'
  $http_bind                = '0.0.0.0'
  $exporter_listen_address  = '127.254.254.254:63382'

  confine($letsencrypt,
    !$acme_contact,
    'Need **acme_contact** parameter, if letsencrypt is enabled'
  )

  # The checked out tag drives the whole setup: the upstream docker-compose.yml
  # in this repo defines images, environment and cron jobs for that version, so
  # bumping $version is all an upgrade needs.
  vcsrepo { $install_dir:
    ensure   => ensure_present($manage),
    provider => 'git',
    source   => 'https://github.com/mailcow/mailcow-dockerized.git',
    revision => $version,
  }

  $_timer = @("EOT"/$n)
    # THIS FILE IS MANAGED BY LINUXAID. CHANGES WILL BE LOST.
    [Unit]
    Requires=mailcow-backup.service
    Description=Mailcow backup script timer

    [Install]
    WantedBy=timers.target

    [Timer]
    OnCalendar=*-*-* 02:15:00
    Unit=mailcow-backup.service
    RandomizedDelaySec=300s
    | EOT

  $_service = @("EOT"/$n)
    # THIS FILE IS MANAGED BY LINUXAID. CHANGES WILL BE LOST.
    [Unit]
    Description=Mailcow backup script service
    Wants=mailcow-backup.timer

    [Service]
    Type=simple
    Environment="PATH=/usr/sbin:/usr/bin:/sbin:/bin"
    Environment="BACKUP_LOCATION=${backup_dir}"
    Environment="CREATE_BACKUP_LOCATION=yes"
    ExecStart=${install_dir}/helper-scripts/backup_and_restore.sh backup all --delete-days 5
    | EOT

  systemd::timer { 'mailcow-backup.timer':
    ensure          => ensure_present($manage),
    timer_content   => $_timer,
    service_content => $_service,
    active          => $manage,
    enable          => $manage,
    require         => Vcsrepo[$install_dir],
  }

  # Firewall
  firewall_multi { '000 allow http request':
    dport => [443, 80],
    proto => 'tcp',
    jump  => 'accept',
  }

  firewall_multi { '000 allow smtp request':
    dport => [25, 465],
    proto => 'tcp',
    jump  => 'accept',
  }

  firewall_multi { '000 allow imap and submission request':
    dport => [587, 143, 993],
    proto => 'tcp',
    jump  => 'accept',
  }

  # Pre 2026-11b setups kept their compose files here, the project now runs
  # from ${install_dir} so mailcow's own helper scripts find everything.
  file { '/opt/obmondo/docker-compose/mailcow':
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Docker_compose['mailcow'],
  }

  file { default:
    ensure  => ensure_present($manage),
    require => Vcsrepo[$install_dir],
    ;
    "${install_dir}/data/assets/ssl":
      ensure => ensure_dir($manage),
    ;
    # mailcow reads mailcow.conf, docker compose reads .env from the project
    # directory; upstream links them the same way.
    "${install_dir}/.env":
      ensure => ensure_present($manage, 'link'),
      target => 'mailcow.conf',
    ;
    "${install_dir}/mailcow.conf":
      content => anything_to_ini({
        'MAILCOW_HOSTNAME'              => $domain,
        'MAILCOW_PASS_SCHEME'           => 'BLF-CRYPT',
        'DBNAME'                        => 'mailcow',
        'DBUSER'                        => 'mailcow',
        'DBPASS'                        => $dbpass,
        'DBROOT'                        => $dbroot,
        'REDISPASS'                     => $redispass,
        'HTTP_BIND'                     => $http_bind,
        'HTTPS_BIND'                    => $http_bind,
        'DOVEADM_PORT'                  => '127.0.0.1:19991',
        'SQL_PORT'                      => '127.0.0.1:13306',
        'SOLR_PORT'                     => '127.0.0.1:18983',
        'REDIS_PORT'                    => '127.0.0.1:7654',
        'TZ'                            => $timezone,
        'COMPOSE_PROJECT_NAME'          => 'mailcow',
        'DOCKER_COMPOSE_VERSION'        => 'native',
        'ACL_ANYONE'                    => 'disallow',
        'MAILDIR_GC_TIME'               => 7200,
        'SKIP_LETS_ENCRYPT'             => to_yn(!$letsencrypt),
        'ACME_ACCOUNT_EMAIL'            => $acme_contact,
        'AUTODISCOVER_SAN'              => 'n',
        'ENABLE_SSL_SNI'                => 'n',
        'SKIP_IP_CHECK'                 => 'n',
        'SKIP_HTTP_VERIFICATION'        => 'y',
        'SKIP_CLAMD'                    => 'n',
        'SKIP_SOGO'                     => 'n',
        'SOLR_HEAP'                     => 1024,
        'ALLOW_ADMIN_EMAIL_LOGIN'       => 'n',
        'USE_WATCHDOG'                  => 'y',
        'WATCHDOG_NOTIFY_BAN'           => 'n',
        'WATCHDOG_NOTIFY_EMAIL'         => 'root@localhost',
        'WATCHDOG_EXTERNAL_CHECKS'      => 'n',
        'WATCHDOG_VERBOSE'              => 'n',
        'LOG_LINES'                     => 9999,
        'IPV4_NETWORK'                  => '172.22.1',
        'IPV6_NETWORK'                  => 'fd4d:6169:6c63:6f77::/64',
        'MAILDIR_SUB'                   => 'Maildir',
        'SOGO_EXPIRE_SESSION'           => 480,
        'WEBAUTHN_ONLY_TRUSTED_VENDORS' => 'n',
        'ADDITIONAL_SAN'                => '',
        'SKIP_UNBOUND_HEALTHCHECK'      => to_yn($skip_unbound_healthcheck),
        'EXPORTER_LISTEN_ADDRESS'       => $exporter_listen_address,
        'MAILCOW_EXPORTER_HOST'         => $domain,
        'MAILCOW_EXPORTER_API_KEY'      => $exporter_api_key,
      }).node_encrypt::secret,
    ;
    "${install_dir}/docker-compose.override.yml":
      content => epp('profile/mail/mailcow/docker-compose.override.yml.epp', {
        'letsencrypt'    => $letsencrypt,
        'exporter_image' => 'ghcr.io/obmondo/dockerfiles/mailcow-exporter:1.4.0',
        'ipv6nat_image'  => 'docker.io/robbertkl/ipv6nat',
      }),
    ;
  }

  # NOTE: multi domain support can be added later, letsencrypt support 100 SANs
  if ! $letsencrypt {
    $_base_dir = lookup('common::system::certs::__base_dir')
    $x_name = regsubst($domain, '^(\w+)(.*)$', '\1')

    $_cert_file = "${_base_dir}/parts/${x_name}/cert.pem"
    $_cert_ca   = "${_base_dir}/parts/${x_name}/ca.pem"

    $_cert_combined_parts = [
      $_cert_file,
      $_cert_ca
    ].delete_undef_values

    # https://docs.mailcow.email/post_installation/firststeps-ssl/#how-to-use-your-own-certificate
    exec { "write combined cert with ca ${x_name}":
      command     => "cat ${_cert_combined_parts.join(' ')} > ${install_dir}/data/assets/ssl/cert.pem",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      refreshonly => true,
      creates     => "${install_dir}/data/assets/ssl/cert.pem",
      require     => Vcsrepo[$install_dir],
    }

    file { "${install_dir}/data/assets/ssl/key.pem":
      notify  => Docker_compose['mailcow'],
      require => Vcsrepo[$install_dir],
      source  => "file://${_base_dir}/parts/${x_name}/key.pem",
    }
  }

  dhparam { "${install_dir}/data/assets/ssl/dhparams.pem":
    size => 2048,
  }

  # Extra setting that can be replaced.
  file { "${install_dir}/data/conf/postfix/extra.cf":
    ensure  => present,
    content => epp('profile/mail/mailcow/extra.epp', {
      myhostname     => $domain,
      extra_settings => $extra_settings,
    })
  }

  docker_compose { 'mailcow':
    ensure        => ensure_present($manage),
    compose_files => [
      "${install_dir}/docker-compose.yml",
      "${install_dir}/docker-compose.override.yml",
    ],
    require       => [
      Vcsrepo[$install_dir],
      File["${install_dir}/.env", "${install_dir}/mailcow.conf", "${install_dir}/docker-compose.override.yml"],
    ],
  }

  # NOTE: lets stop postfix on the host
  service { 'postfix':
    ensure => stopped,
  }

  $host = $::trusted['certname']
  $exporter_port = Integer($exporter_listen_address.split(':')[1])

  @@prometheus::scrape_job { 'mailcow' :
    job_name    => 'mailcow',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${exporter_port}" ],
    labels      => { 'certname' => $host },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
