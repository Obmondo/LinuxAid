
# @summary Class for managing the Postfix mail server
#
# @param manage Whether to manage the Postfix service. Defaults to false.
#
# @param inet_interfaces The interfaces Postfix should listen on. Defaults to 'localhost'.
#
# @param myhostname The hostname for the mail server.
#
# @param mydomain The domain for the mail server. Defaults to undef.
#
# @param relayhost The relay host for the mail server. Defaults to undef.
#
# @param smtp_sasl_auth Whether to enable SMTP SASL authentication. Defaults to false.
#
# @param smtp_sasl_password_maps The SASL password maps. Defaults to undef.
#
# @param smtp_sasl_security_options The security options for SASL. Defaults to undef.
#
# @param default_destination_concurrency_limit The default limit for destination concurrency. Defaults to 20.
#
# @param soft_bounce Whether to enable soft bounces. Defaults to false.
#
# @param smtp_connection_cache_destinations List of SMTP connection cache destinations. Defaults to [].
#
# @param smtp_tls_security_level The security level for SMTP TLS. Defaults to 'encrypt'.
#
# @param smtp_tls_loglevel The log level for SMTP TLS. Defaults to 1.
#
# @param smtpd_tls_auth_only Whether to require TLS for authentication. Defaults to 'yes'.
#
# @param tls_ssl_options The SSL options for TLS. Defaults to 'NO_COMPRESSION'.
#
# @param smtpd_tls_protocols The TLS protocols for the server. Defaults to '!SSLv2,!SSLv3'.
#
# @param smtpd_tls_mandatory_protocols The mandatory TLS protocols. Defaults to '!SSLv2,!SSLv3'.
#
# @param smtpd_tls_mandatory_ciphers The mandatory ciphers for TLS. Defaults to 'high'.
#
# @param smtpd_tls_eecdh_grade The ECDH grade for TLS. Defaults to 'ultra'.
#
# @param tls_preempt_cipherlist Whether to preempt the cipher list. Defaults to 'yes'.
#
# @param tls_high_cipherlist The high cipher list for TLS. Defaults to the provided long string.
#
# @param stats_daemon_port The port for the stats daemon. Defaults to 63777.
#
# @param run_newaliases Whether to run newaliases after configuration changes. Defaults to true.
#
# @param aliases The alias mappings for the mail server. Defaults to {}.
#
# @param _extra_main_parameters Any extra main parameters for Postfix. Defaults to {}.
#
# @param maildrop_perms The permissions for mail drops. Defaults to 'u+rwX,g-r,g+wX'.
#
# @param noop_value A value for no-operation configurations. Defaults to undef.
#
class role::mail::postfix (
  Boolean $manage                                            = false,
  Variant[    Eit_types::IP,    Enum['all', 'localhost']  ] $inet_interfaces                                         = 'localhost',
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
  String $tls_high_cipherlist                                = 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
  Stdlib::Port $stats_daemon_port                            = 63777,
  Boolean $run_newaliases                                    = true,
  Hash[String, String] $aliases                              = {},
  Hash[String, String] $_extra_main_parameters               = {},
  Variant[Stdlib::Filemode,String] $maildrop_perms           = 'u+rwX,g-r,g+wX',
  Optional[Boolean] $noop_value                              = undef,
) {
  class { 'common::mail':
    manage                                => $manage,
    inet_interfaces                       => $inet_interfaces,
    myhostname                            => $myhostname,
    mydomain                              => $mydomain,
    relayhost                             => $relayhost,
    smtp_sasl_auth                        => $smtp_sasl_auth,
    smtp_sasl_password_maps               => $smtp_sasl_password_maps,
    smtp_sasl_security_options            => $smtp_sasl_security_options,
    default_destination_concurrency_limit => $default_destination_concurrency_limit,
    soft_bounce                           => $soft_bounce,
    smtp_connection_cache_destinations    => $smtp_connection_cache_destinations,
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
    stats_daemon_port                     => $stats_daemon_port,
    run_newaliases                        => $run_newaliases,
    aliases                               => $aliases,
    maildrop_perms                        => $maildrop_perms,
    noop_value                            => $noop_value,
  }
}
