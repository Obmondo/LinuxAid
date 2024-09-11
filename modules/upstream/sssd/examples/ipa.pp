class {'::sssd':
  config => {
    'sssd'                  => {
      'domains'             => 'example.com',
      'config_file_version' => 2,
      'services'            => ['nss', 'sudo', 'pam', 'ssh'],
    },
    'domain/ad.example.com' => {
      'ipa_domain'                     => 'example.com',
      'ipa_server'                     => ['ipaserver1.example.com', 'ipaserver2.example.com'],
      'ipa_hostname'                   => 'client1.example.com',
      'id_provider'                    => 'ipa',
      'access_provider'                => 'ipa',
      'chpass_provider'                => 'ipa',
      'cache_credentials'              => true,
      'krb5_store_password_if_offline' => true,
      'ldap_tls_cacert'                => '/etc/ipa/ca.crt',
    }
  }
}
