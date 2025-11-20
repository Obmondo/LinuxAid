# @summary Class for managing common postfix mail setup
#
# @param manage Boolean flag to manage the mail configuration. Defaults to false.
#
# @param inet_interfaces The network interfaces. Defaults to 'localhost'.
#
# @param myhostname The server's hostname.
#
# @param mydomain Optional domain name.
#
# @param relayhost Optional relay host. Defaults to undef.
#
# @param smtp_sasl_auth Boolean to enable SMTP SASL authentication. Defaults to false.
#
# @param smtp_sasl_password_maps Optional SMTP SASL password maps. Defaults to undef.
#
# @param smtp_sasl_security_options Optional SMTP SASL security options. Defaults to undef.
#
# @param default_destination_concurrency_limit Maximum number of concurrent delivery attempts. Defaults to 20.
#
# @param soft_bounce Boolean to enable soft bounce. Defaults to false.
#
# @param smtp_connection_cache_destinations Array of destinations for SMTP connection caching. Defaults to empty array.
#
# @param smtp_tls_security_level TLS security level. Defaults to 'encrypt'.
#
# @param smtp_tls_loglevel TLS log level. Defaults to 1.
#
# @param smtpd_tls_auth_only Whether TLS authentication is required. Defaults to 'yes'.
#
# @param tls_ssl_options SSL options for TLS. Defaults to 'NO_COMPRESSION'.
#
# @param smtpd_tls_protocols TLS protocols for SMTP daemon. Defaults to '!SSLv2,!SSLv3'.
#
# @param smtpd_tls_mandatory_protocols Mandatory TLS protocols. Defaults to '!SSLv2,!SSLv3'.
#
# @param smtpd_tls_mandatory_ciphers Ciphers for mandatory TLS. Defaults to 'high'.
#
# @param smtpd_tls_eecdh_grade ECDH grade for TLS. Defaults to 'ultra'.
#
# @param tls_preempt_cipherlist Whether to preempt cipher list. Defaults to 'yes'.
#
# @param tls_high_cipherlist Cipher list for high security cipher suites. Defaults to a long cipher string.
#
# @param stats_daemon_port Port for stats daemon. Defaults to 63777.
#
# @param run_newaliases Boolean to run `newaliases`. Defaults to true.
#
# @param aliases Hash of mail aliases. Defaults to empty hash.
#
# @param _extra_main_parameters Additional parameters for main config. Defaults to empty hash.
#
# @param maildrop_perms Permissions for maildrop directory. Defaults to 'u+rwX,g-r,g+wX'.
#
# @param noop_value Optional noop value. Defaults to undef.
#
class common::mail (
  Boolean $manage                                            = false,
  Variant[
    Eit_types::IP,
    Enum['all', 'localhost']
  ] $inet_interfaces                                         = 'localhost',
  Eit_types::Hostname $myhostname,
  Optional[Eit_types::Domain] $mydomain,
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
  Eit_types::Noop_Value $noop_value                          = undef,
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
        myhostname                 => $myhostname,
        mydomain                   => $mydomain,
        relayhost                  => $relayhost,
        inet_interfaces            => $inet_interfaces,
        smtp_sasl_auth             => $smtp_sasl_auth,
        smtp_sasl_password_maps    => $smtp_sasl_password_maps,
        smtp_sasl_security_options => $smtp_sasl_security_options,
        extra_main_parameters      => stdlib::merge({
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
        onlyif => '/usr/bin/test \( ! -f /etc/aliases.db \) -o \( /etc/aliases.db -ot /etc/aliases \)',
      }
    }
    file { default:
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
