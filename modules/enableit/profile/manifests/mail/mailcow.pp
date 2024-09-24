# Mailcow Setup
class profile::mail::mailcow (
  Boolean                     $manage           = $role::mail::mailcow::manage,
  Boolean                     $letsencrypt      = $role::mail::mailcow::letsencrypt,
  Optional[Eit_types::Email]  $acme_contact     = $role::mail::mailcow::acme_contact,
  Eit_types::Mailcow::Version $version          = $role::mail::mailcow::version,
  Stdlib::Unixpath            $install_dir      = $role::mail::mailcow::install_dir,
  Eit_types::Timezone         $timezone         = $role::mail::mailcow::timezone,
  String                      $dbroot           = $role::mail::mailcow::dbroot,
  String                      $dbpass           = $role::mail::mailcow::dbpass,
  Optional[Hash]              $extra_settings   = $role::mail::mailcow::extra_settings,
  Stdlib::Fqdn                $domain           = $role::mail::mailcow::domain,
  Integer[3,30]               $backup_retention = $role::mail::mailcow::backup_retention,

  Stdlib::IP::Address::V4::Nosubnet $http_bind  = $role::mail::mailcow::http_bind,
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

  cron::daily { 'mailcow-backup':
    command     => "${install_dir}/helper-scripts/backup_and_restore.sh backup all --delete-days ${backup_retention}",
    environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
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
      "${install_dir}/data/assets/ssl",
    ]:
    ;
    '/opt/obmondo/docker-compose/mailcow/.env':
      ensure  => present,
      content => anything_to_ini({
        # NOTE: hostname and domains inside mailcow can't be same
        # but its a edge case, when its just an internal domain
        # with same name as mail domain
        'MAILCOW_HOSTNAME'              => $domain,
        'MAILCOW_PASS_SCHEME'           => 'BLF-CRYPT',
        'DBNAME'                        => 'mailcow',
        'DBUSER'                        => 'mailcow',
        'DBPASS'                        => $dbpass,
        'DBROOT'                        => $dbroot,
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
        'SKIP_SOLR'                     => 'y',
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
      }),
    ;
    '/opt/obmondo/docker-compose/mailcow/docker-compose.yaml':
      ensure  => ensure_present($manage),
      content => epp('profile/docker-compose/mailcow/docker-compose.yaml.epp', {
        'install_dir' => $install_dir,
        'ssl_dir'     => "/etc/letsencrypt/live/${domain}/"
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
      '/opt/obmondo/docker-compose/mailcow/docker-compose.yaml',
    ],
    require       => File['/opt/obmondo/docker-compose/mailcow/docker-compose.yaml'],
  }
}
