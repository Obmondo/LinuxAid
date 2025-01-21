# Common postfix setup for all servers
class common::mail (
  Boolean $manage                                            = false,
  Variant[
    Eit_types::IP,
    Enum['all', 'localhost']
  ] $inet_interfaces                                         = 'localhost',
  Optional[Eit_types::Host] $relayhost                       = undef,
  Boolean $smtp_sasl_auth                                    = false,
  Optional[String] $smtp_sasl_password_maps                  = undef,
  Optional[String] $smtp_sasl_security_options               = undef,
  Integer[0, default] $default_destination_concurrency_limit = 20,
  Boolean $soft_bounce                                       = false,
  Array[String] $smtp_connection_cache_destinations          = [],
  Eit_types::Postfix_Security_Level $smtp_tls_security_level = 'encrypt',
  Integer[0] $smtp_tls_loglevel                              = 1,
  Enum['yes', 'no'] $smtpd_tls_auth_only                     = 'yes',
  String $tls_ssl_options                                    = 'NO_COMPRESSION',
  String $smtpd_tls_protocols                                = '!SSLv2,!SSLv3',
  String $smtpd_tls_mandatory_protocols                      = '!SSLv2,!SSLv3',
  String $smtpd_tls_mandatory_ciphers                        = 'high',
  String $smtpd_tls_eecdh_grade                              = 'ultra',
  String $tls_preempt_cipherlist                             = 'yes',
  String $tls_high_cipherlist                                = 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA', #lint:ignore:140chars
  Stdlib::Port $stats_daemon_port                         = 63777,
  Boolean $run_newaliases                                    = true,
  Hash[String, String] $aliases                              = {},
  Hash[String, String] $_extra_main_parameters               = {},
  Variant[Stdlib::Filemode,String] $maildrop_perms           = 'u+rwX,g-r,g+wX',
  Optional[Boolean] $noop_value                              = undef,
) {
  $real_soft_bounce = to_yesno($soft_bounce)

  if $manage {
    $has_mail_server_role = $::obmondo_classes.grep('role::mail::').size
    if $has_mail_server_role {
      # we only want to setup as normal "outgoing only" mail server - if server
      # does not have role::mail::$something :)
      if $facts[os][family] == 'RedHat' {
        package::install('ssmtp', { ensure => absent })
      }

      class { 'postfix::server':
        myhostname                 => $facts['fqdn'],
        mydomain                   => $facts.dig('domain'),
        relayhost                  => $relayhost,
        inet_interfaces            => $inet_interfaces,
        smtp_sasl_auth             => $smtp_sasl_auth,
        smtp_sasl_password_maps    => $smtp_sasl_password_maps,
        smtp_sasl_security_options => $smtp_sasl_security_options,
        extra_main_parameters      => merge({
          smtp_tls_security_level               => $smtp_tls_security_level,
          smtp_tls_loglevel                     => $smtp_tls_loglevel,
          smtpd_tls_auth_only                   => $smtpd_tls_auth_only,
          tls_ssl_options                       => $tls_ssl_options,
          smtpd_tls_protocols                   => $smtpd_tls_protocols,
          smtpd_tls_mandatory_protocols         => $smtpd_tls_mandatory_protocols,
          smtpd_tls_mandatory_ciphers           => $smtpd_tls_mandatory_ciphers,
          smtpd_tls_eecdh_grade                 => $smtpd_tls_eecdh_grade,
          tls_preempt_cipherlist                => $tls_preempt_cipherlist,
          tls_high_cipherlist                   => $tls_high_cipherlist,
          default_destination_concurrency_limit => $default_destination_concurrency_limit,
          soft_bounce                           => $real_soft_bounce,
          smtp_connection_cache_destinations    => $smtp_connection_cache_destinations,
        }, $_extra_main_parameters),
      }
    }

    if $run_newaliases {
      # Run `newaliases` if needed
      exec { '/usr/bin/newaliases':
        # only run `newaliases` if the db is either missing or older than the
        # aliases file
        onlyif => '/usr/bin/test \( ! -f /etc/aliases.db \) -o \( /etc/aliases.db -ot /etc/aliases \)',
      }
    }

    file {
      default:
        ensure => 'directory',
        owner  => 'postfix',
        group  => 'postfix',
        ;

      '/var/spool/postfix':
        ;

      '/var/spool/postfix/maildrop':
        group => 'postdrop',
        mode  => lookup('common::mail::maildrop_perms'),
    }

    $aliases.map |$target, $recipient| {
      mailalias { $target:
        ensure    => present,
        recipient => $recipient,
        noop      => $noop_value,
      }
    }
  }
}
