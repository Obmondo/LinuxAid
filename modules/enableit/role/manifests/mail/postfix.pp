
# @summary Class for managing the Postfix mail server
#
# @param manage Whether to manage the Postfix service. Defaults to false.
#
# @groups management manage.
#
class role::mail::postfix (
  Boolean $manage = false,
) {
  class { 'common::system::mail':
    manage                                => $manage,
    inet_interfaces                       => 'localhost',
    relayhost                             => undef,
    smtp_sasl_auth                        => false,
    smtp_sasl_password_maps               => undef,
    smtp_sasl_security_options            => undef,
    default_destination_concurrency_limit => 20,
    soft_bounce                           => false,
    smtp_connection_cache_destinations    => [],
    smtp_tls_security_level               => 'encrypt',
    smtp_tls_loglevel                     => 1,
    smtpd_tls_auth_only                   => 'yes',
    tls_ssl_options                       => 'NO_COMPRESSION',
    smtpd_tls_protocols                   => '!SSLv2,!SSLv3',
    smtpd_tls_mandatory_protocols         => '!SSLv2,!SSLv3',
    smtpd_tls_mandatory_ciphers           => 'high',
    smtpd_tls_eecdh_grade                 => 'ultra',
    tls_preempt_cipherlist                => 'yes',
    tls_high_cipherlist                   => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    stats_daemon_port                     => 63777,
    run_newaliases                        => true,
    aliases                               => {},
    maildrop_perms                        => 'u+rwX,g-r,g+wX',
    noop_value                            => undef,
  }
}
