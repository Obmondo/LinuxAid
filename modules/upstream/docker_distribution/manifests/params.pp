class docker_distribution::params {
  $manage_as = 'service'
  $container_image = 'docker.io/registry:latest'

  case $::osfamily {
    'RedHat'  : {
      $package_name = 'docker-distribution'
      $service_name = 'docker-distribution'
      $config_file  = '/etc/docker-distribution/registry/config.yml'
      $global_ca = '/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem'
    }
    'Suse'    : {
      $package_name = 'docker-distribution-registry'
      $service_name = 'registry'
      $config_file  = '/etc/registry/config.yml'
    }
    'Debian'    : {
      $package_name = 'docker-distribution'
      $service_name = 'docker-distribution'
      $config_file  = '/etc/docker-distribution/registry/config.yml'
      $global_ca = '/etc/ssl/certs/ca-certificates.crt'
    }
    default : {
      fail("Distribution not supported: ${::osfamily}.")
    }
  }

  $package_ensure = 'installed'
  $service_ensure = 'running'
  $service_enable = true
  $journald_forward_enable = false
  $mount_global_ca = false

  $log_level = 'info'
  $log_formatter = 'text'
  $log_fields = undef

  $log_hooks_mail_disabled = true
  $log_hooks_mail_levels = ['panic']
  $log_hooks_mail_smtp_addr = "smtp.${::domain}:25"
  $log_hooks_mail_smtp_username = 'mailuser'
  $log_hooks_mail_smtp_password = 'mailpass'
  $log_hooks_mail_smtp_insecure = true
  $log_hooks_mail_from = "docker-registry@${::fqdn}"
  $log_hooks_mail_to = []

  $storage_type = 'filesystem'
  $filesystem_rootdirectory = '/var/lib/registry'

  $azure_accountname = 'accountname'
  $azure_accountkey = 'base64encodedaccountkey'
  $azure_container = 'containername'
  $azure_realm = 'core.windows.net'

  $gcs_bucket = 'bucketname'
  $gcs_keyfile = '/path/to/keyfile'
  $gcs_rootdirectory = '/gcs/object/name/prefix'

  $s3_accesskey = 'awsaccesskey'
  $s3_secretkey = 'awssecretkey'
  $s3_region = 'us-west-1'
  $s3_bucket = 'bucketname'
  $s3_encrypt = true
  $s3_secure = true
  $s3_v4auth = true
  $s3_chunksize = '5242880'
  $s3_rootdirectory = '/s3/object/name/prefix'

  $rados_poolname = 'radospool'
  $rados_username = 'radosuser'
  $rados_chunksize = '4194304'

  $swift_username = 'username'
  $swift_password = 'password'
  $swift_authurl = 'https://storage.myprovider.com/auth/v1.0 or https://storage.myprovider.com/v2.0 or https://storage.myprovider.com/v3/auth'
  $swift_tenant = 'tenantname'
  $swift_tenantid = 'tenantid'
  $swift_domain = 'domain name for Openstack Identity v3 API'
  $swift_domainid = 'domain id for Openstack Identity v3 API'
  $swift_insecureskipverify = true
  $swift_region = 'fr'
  $swift_container = 'containername'
  $swift_rootdirectory = '/swift/object/name/prefix'
  $swift_trustid = 'swift_trustid'
  $swift_chunksize = '5M'

  $storage_delete = false
  $storage_redirect = false
  $storage_cache_blobdescriptor = 'inmemory'

  $auth_type = undef

  $auth_token_realm = 'token-realm'
  $auth_token_service = 'Docker registry'
  $auth_token_issuer = 'Auth Service'
  $auth_token_rootcertbundle = '/etc/ssl/certs/'

  $auth_htpasswd_realm = 'basic-realm'
  $auth_htpasswd_path = '/path/to/htpasswd'

  $http_addr = 'localhost:5000'
  $http_net = 'tcp'
  $http_prefix = '/'
  $http_host = undef
  $http_secret = undef
  $http_tls = false
  $http_tls_certificate = "${::settings::ssldir}/certs/${::clientcert}.pem"
  $http_tls_key = "${::settings::ssldir}/private_keys/${::clientcert}.pem"
  $http_tls_clientcas = undef
  $http_debug_addr = undef
  $http_headers = {
    'X-Content-Type-Options' => '[nosniff]',
  }

  $notifications_name = $::fqdn
  $notifications_disabled = false
  $notifications_url = undef
  $notifications_headers = undef
  $notifications_timeout = 500
  $notifications_threshold = 5
  $notifications_backoff = 1000

  $redis_addr = undef
  $redis_password = undef
  $redis_db = '0'
  $redis_dialtimeout = '10ms'
  $redis_readtimeout = '10ms'
  $redis_writetimeout = '10ms'
  $redis_pool_maxidle = '16'
  $redis_pool_maxactive = '64'
  $redis_pool_idletimeout = '300s'

  $proxy_remoteurl = undef
  $proxy_username = undef
  $proxy_password = undef
}
