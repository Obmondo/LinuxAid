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
# @param mynetworks List of trusted clients (IPs/CIDRs) allowed to relay through this server. Empty disables explicit mynetworks. Defaults to empty array.
#
# @param smtp_tls_security_level TLS security level. Defaults to 'encrypt'.
#
# @param aliases Hash of mail aliases. Defaults to empty hash.
#
# @param _extra_main_parameters Additional parameters for main config. Defaults to empty hash.
#
# @param noop_value Optional noop value. Defaults to undef.
#
# @groups main manage, myhostname, mydomain, relayhost, aliases, _extra_main_parameters.
#
# @groups smtp smtp_tls_security_level.
#
# @groups performance inet_interfaces.
#
# @groups permissions noop_value.
#
class common::system::mail (
  Boolean $manage                                            = false,
  Variant[
    Eit_types::IP,
    Enum['all', 'localhost']
  ] $inet_interfaces                                         = 'localhost',
  Eit_types::Hostname $myhostname,
  Optional[Eit_types::Domain] $mydomain,
  Optional[Eit_types::Host] $relayhost                       = undef,
  Array[String] $mynetworks                                  = [],
  Eit_types::Postfix_Security_Level $smtp_tls_security_level = 'encrypt',
  Hash[String, String] $aliases                              = {},
  Hash[String, String] $_extra_main_parameters               = {},
  Eit_types::Noop_Value $noop_value                          = undef,
) {
  if $manage {
    $has_mail_server_role = $::obmondo_classes.grep('role::mail::').size
    if $has_mail_server_role {
      # we only want to setup as normal "outgoing only" mail server - if server
      # does not have role::mail::$something :)
      if $facts[os][family] == 'RedHat' {
        package::install('ssmtp', { ensure => absent })
      }
      # postfix::server treats `false` as "leave unset"; only emit this when
      # the caller actually supplied entries.
      $real_mynetworks = $mynetworks =~ Array[Any, 1] ? { true => $mynetworks, default => false }
      class { 'postfix::server':
        myhostname                 => $myhostname,
        mydomain                   => $mydomain,
        relayhost                  => $relayhost,
        mynetworks                 => $real_mynetworks,
        relay_domains              => false,
        inet_interfaces            => $inet_interfaces,
        smtp_sasl_auth             => false,
        smtp_sasl_password_maps    => undef,
        smtp_sasl_security_options => undef,
        extra_main_parameters      => stdlib::merge({
          smtp_tls_security_level               => $smtp_tls_security_level,
          smtp_tls_loglevel                     => 1,
          smtpd_tls_auth_only                   => 'yes',
          tls_ssl_options                       => 'NO_COMPRESSION',
          smtpd_tls_protocols                   => '!SSLv2,!SSLv3',
          smtpd_tls_mandatory_protocols         => '!SSLv2,!SSLv3',
          smtpd_tls_mandatory_ciphers           => 'high',
          smtpd_tls_eecdh_grade                 => 'ultra',
          tls_preempt_cipherlist                => 'yes',
          tls_high_cipherlist                   => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA', #lint:ignore:140chars
          default_destination_concurrency_limit => 20,
          soft_bounce                           => 'no',
          smtp_connection_cache_destinations    => [],
        }, $_extra_main_parameters),
      }
    }
    exec { '/usr/bin/newaliases':
      onlyif => '/usr/bin/test \( ! -f /etc/aliases.db \) -o \( /etc/aliases.db -ot /etc/aliases \)',
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
        mode  => lookup('common::system::mail::maildrop_perms'),
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
