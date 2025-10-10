class { 'sssd':
  config => {
    'sssd'               => {
      'domains'             => 'example.com',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    'domain/example.com' => {
      'access_provider'    => 'simple',
      'simple_allow_users' => ['user1', 'user2'],
    },
  },
}
