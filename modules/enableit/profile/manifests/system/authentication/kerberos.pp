# Kerberos integration
class profile::system::authentication::kerberos (
  Boolean          $enable  = $common::system::authentication::kerberos::enable,
  Optional[String] $base_dn = $common::system::authentication::kerberos::base_dn,
  Optional[String] $ou      = $common::system::authentication::kerberos::ou,

  Eit_types::Domain             $default_realm  = $common::system::authentication::kerberos::default_realm,
  Boolean                       $join           = $common::system::authentication::kerberos::join,
  Optional[Hash]                $appdefaults    = $common::system::authentication::kerberos::appdefaults,
  Optional[Eit_types::Password] $join_password  = $common::system::authentication::kerberos::join_password,
  Optional[Eit_types::User]     $join_user      = $common::system::authentication::kerberos::join_user,
  Boolean                       $install_client = $common::system::authentication::kerberos::install_client,
  Boolean                       $ldaps          = $common::system::authentication::kerberos::ldaps,
  Optional[Boolean]             $noop_value     = $common::system::authentication::kerberos::noop_value,
  Optional[Stdlib::Unixpath]    $cacert_path    = $common::system::authentication::kerberos::cacert_path,

  Eit_types::Common::System::Authentication::Kerberos::Realms $realms = $common::system::authentication::kerberos::realms,
) {

  Concat {
    noop => $noop_value,
  }
  Concat::Fragment {
    noop => $noop_value,
  }
  Exec {
    noop => $noop_value,
  }
  File {
    noop => $noop_value,
  }
  Ini_setting {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }

  if $enable {

    class { 'mit_krb5':
      default_realm    => $default_realm,
      dns_lookup_realm => false,
      dns_lookup_kdc   => false,
      ticket_lifetime  => '24h',
      renew_lifetime   => '7d',
      forwardable      => true,
      noop_value       => $noop_value,
    }

    class { 'mit_krb5::logging':
      defaults     => 'FILE:/var/log/krb5libs.log',
      admin_server => 'FILE:/var/log/kadmind.log',
      kdc          => 'FILE:/var/log/krb5kdc.log'
    }

    $realms.each |$_realm, $_options| {
      mit_krb5::realm { $_realm:
        *      => $_options,
        notify => Service['sssd']
      }

    }

    $_default_domain = $realms[$default_realm]['default_domain']
    mit_krb5::domain_realm { $default_realm:
      domains => [
        $_default_domain,
        ".${_default_domain}",
      ]
    }

    if $appdefaults {
      $appdefaults.each |$key, $value| {
        mit_krb5::appdefaults { $key:
          debug           => $value['debug'],
          ticket_lifetime => $value['ticket_lifetime'],
          renew_lifetime  => $value['renew_lifetime'],
          forwardable     => $value['forwardable'],
          krb4_convert    => $value['krb4_convert'],
        }
      }
    }

    if $join {
      class { 'realmd':
        domain               => $default_realm,
        ou                   => $ou,
        domain_join_user     => $join_user,
        domain_join_password => $join_password,
        krb_ticket_join      => false,
        manage_sssd_config   => false,
        manage_krb_config    => false,
        before               => Class['sssd'],
        notify               => Service['sssd'],
      }
    }

    if $install_client {
      package::install('openldap-clients')

      $_ldap_conf_path = $facts.dig('os', 'family') ? {
        /RedHat|Suse/ => '/etc/openldap/ldap.conf',
        'Debian'      => '/etc/ldap/ldap.conf',
      }

      $_ldap = if $ldaps { 'ldaps' } else { 'ldap' }
      $_uri = "${_ldap}://${$realms[$default_realm]['kdc'].downcase}"

      # NOTE: TLS_CACERTDIR does not work, since opeldap uses GnuTLS and not OpenSSL on Debian.
      $_ldap_cacert_path = if $cacert_path and $facts.dig('os', 'family') == 'Debian' {
        $cacert_path
      } else {
        '/etc/pki/tls/certs/ca-bundle.crt'
      }

      file { $_ldap_conf_path:
        ensure  => ensure_present($enable),
        content => epp('profile/system/authentication/ldap.conf.epp', {
          'uri'        => $_uri,
          'base'       => $base_dn,
          'tls_cacert' => $_ldap_cacert_path,
        }),
        require => Package['openldap-clients'],
      }
    }
  }

}
