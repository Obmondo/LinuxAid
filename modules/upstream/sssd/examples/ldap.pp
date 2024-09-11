class {'::sssd':
  config => {
    'sssd'               => {
      'domains'             => 'example.com',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    'domain/example.com' => {
      'id_provider'           => 'ldap',
      'auth_provider'         => 'ldap',
      'cache_credentials'     => true,
      'ldap_uri'              => 'ldap://ldap.example.com',
      'ldap_search_base'      => 'dc=example,dc=com',
      'ldap_id_use_start_tls' => true,
      'ldap_tls_reqcert'      => 'demand',
      'ldap_tls_cacert'       => '/etc/pki/tls/certs/ca-bundle.crt',
    }
  }
}
