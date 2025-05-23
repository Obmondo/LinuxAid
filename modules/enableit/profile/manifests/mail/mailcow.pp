# Mailcow Setup
class profile::mail::mailcow (
  Boolean                     $manage                   = $role::mail::mailcow::manage,
  Boolean                     $letsencrypt              = $role::mail::mailcow::letsencrypt,
  Optional[Eit_types::Email]  $acme_contact             = $role::mail::mailcow::acme_contact,
  Eit_types::Mailcow::Version $version                  = $role::mail::mailcow::version,
  Stdlib::Unixpath            $install_dir              = $role::mail::mailcow::install_dir,
  Stdlib::Unixpath            $backup_dir               = $role::mail::mailcow::backup_dir,
  Eit_types::Timezone         $timezone                 = $role::mail::mailcow::timezone,
  String                      $dbroot                   = $role::mail::mailcow::dbroot,
  String                      $dbpass                   = $role::mail::mailcow::dbpass,
  String                      $redispass                = $role::mail::mailcow::redispass,
  Optional[Hash]              $extra_settings           = $role::mail::mailcow::extra_settings,
  Stdlib::Fqdn                $domain                   = $role::mail::mailcow::domain,
  Integer[3,30]               $backup_retention         = $role::mail::mailcow::backup_retention,
  String                      $exporter_image           = $role::mail::mailcow::exporter_image,
  Eit_types::IPPort           $exporter_listen_address  = $role::mail::mailcow::exporter_listen_address,
  String                      $exporter_api_key         = $role::mail::mailcow::exporter_api_key,

  Stdlib::IP::Address::V4::Nosubnet $http_bind          = $role::mail::mailcow::http_bind,
  Optional[Boolean]           $skip_unbound_healthcheck = $role::mail::mailcow::skip_unbound_healthcheck,
) {

  confine($letsencrypt,
    !$acme_contact,
    'Need **acme_contact** parameter, if letsencrypt is enabled'
  )

  vcsrepo { $install_dir:
    ensure   => ensure_present($manage),
    provider => 'git',
    source   => 'https://github.com/mailcow/mailcow-dockerized.git',
    revision => $version,
  }

  # NOTE: we are creating a symlink to the original backup script since our compose file is at diff location, then the expected path
  # in the script. mailcow is working an improvment here https://github.com/mailcow/mailcow-dockerized/pull/6030
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
    ExecStart=/opt/obmondo/docker-compose/mailcow/helper-scripts/backup_and_restore.sh backup all --delete-days ${backup_retention}
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

  file { default:
    ensure  => ensure_dir($manage),
    ;
    [
      '/opt/obmondo/docker-compose/mailcow',
      '/opt/obmondo/docker-compose/mailcow/helper-scripts',
      "${install_dir}/data/assets/ssl",
    ]:
    # TODO: remove this, when the backup PR is merged upstream.
    ;
    '/opt/obmondo/docker-compose/mailcow/helper-scripts/backup_and_restore.sh':
      ensure => link,
      target => "${install_dir}/helper-scripts/backup_and_restore.sh",
    ;
    '/opt/obmondo/docker-compose/mailcow/mailcow.conf':
      ensure => link,
      target => '/opt/obmondo/docker-compose/mailcow/.env',
    ;
    '/opt/obmondo/docker-compose/mailcow/.env':
      ensure  => present,
      content => anything_to_ini({
        'MAILCOW_HOSTNAME'              => $domain,
        'MAILCOW_PASS_SCHEME'           => 'BLF-CRYPT',
        'DBNAME'                        => 'mailcow',
        'DBUSER'                        => 'mailcow',
        'DBPASS'                        => $dbpass,
        'DBROOT'                        => $dbroot,
        'REDISPASS'                     => $redispass.node_encrypt::secret,
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
        'ACME_CONTACT'                  => $acme_contact,
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
      }),
    ;
    # NOTE: These container tag are manually maintained to have a better control
    # on release, based on last commit 75f18df1435b72cb827af1f114f58de92c498f5e
    '/opt/obmondo/docker-compose/mailcow/docker-compose.yml':
      ensure  => ensure_present($manage),
      content => epp('profile/mail/mailcow/docker-compose.yml.epp', {
        'install_dir'     => $install_dir,
        'letsencrypt'     => $letsencrypt,
        'unbound_image'   => 'ghcr.io/mailcow/unbound:1.24',
        'mysql_image'     => 'docker.io/mariadb:10.11',
        'redis_image'     => 'docker.io/redis:7.4.2-alpine',
        'clamd_image'     => 'ghcr.io/mailcow/clamd:1.70',
        'rspamd_image'    => 'ghcr.io/mailcow/rspamd:2.2',
        'php_fpm_image'   => 'ghcr.io/mailcow/phpfpm:1.93',
        'sogo_image'      => 'ghcr.io/mailcow/sogo:1.133',
        'dovecot_image'   => 'ghcr.io/mailcow/dovecot:2.33',
        'postfix_image'   => 'ghcr.io/mailcow/postfix:1.80',
        'memcached_image' => 'docker.io/memcached:alpine',
        'nginx_image'     => 'ghcr.io/mailcow/nginx:1.03',
        'acme_image'      => 'ghcr.io/mailcow/acme:1.92',
        'netfilter_image' => 'ghcr.io/mailcow/netfilter:1.61',
        'watchdog_image'  => 'ghcr.io/mailcow/watchdog:2.08',
        'dockerapi_image' => 'ghcr.io/mailcow/dockerapi:2.11',
        'olefy_image'     => 'ghcr.io/mailcow/olefy:1.15',
        'olefia_image'    => 'docker.io/mcuadros/ofelia:latest',
        'ipv6nat_image'   => 'docker.io/robbertkl/ipv6nat',
        'exporter_image'  => $exporter_image,
      }),
      require => [
        File['/opt/obmondo/docker-compose/mailcow'],
      ],
    ;
  }

  # NOTE: multi domain support can be added later, letsencrypt support 100 SANs
  if ! $letsencrypt {
    $_base_dir = lookup('common::certs::__base_dir')
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
      '/opt/obmondo/docker-compose/mailcow/docker-compose.yml',
    ],
    require       => File['/opt/obmondo/docker-compose/mailcow/docker-compose.yml'],
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
