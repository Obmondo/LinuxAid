# Class: docker_distribution
#
# This module manages docker_distribution
#
# [*manage_as*]
#   How to manage the distribution service. Valid values are: service, container
#   Defaults to service
#
# [*container_image*]
#   From where to pull the image.
#   Defaults to docker.io/registry:latest
#
# [*package_name*]
#   Name of package to be installed
#   Defaults to docker-distribution-registry
#
# [*package_ensure*]
#   Passed to the package resource.
#   Defaults to present
#
# [*config_file*]
#   Path to config file
#   Defaults to /etc/docker-distribution/registry/config.yml
#
# [*service_name*]
#   Name of service to start
#   Defaults to registry
#
# [*service_ensure*]
#   Whether you want to docker_distribution to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to docker_distribution to start up at boot
#   Defaults to true
#
# [*journald_forward_enable*]
#   Fix for SIGPIPE sent to registry daemon during journald restart
#   Defaults to false
#
# [*mount_global_ca*]
#   Based on OS, mount the system ca inside container
#   Defaults to false
#
# [*log_level*]
#   Sets the sensitivity of logging output. Permitted values are error, warn, info and debug.
#   The default is info. 
#
# [*log_formatter*]
#   This selects the format of logging output. The format primarily affects how keyed attributes
#   for a log line are encoded. Options are text, json or logstash.
#   The default is text. 
#
# [*log_fields*]
#   A map of field names to values. These are added to every log line for the context.
#   This is useful for identifying log messages source after being mixed in other systems. 
#   Example:
#    $log_fields = {
#      service     => 'registry',
#      environment => 'staging'
#    }
#   Defaults to undef
#
# [*log_hooks_mail_disabled*]
#   Disable log hook mail
#   Default to true
#
# [*log_hooks_mail_levels*]
#   Array of log levels that will be sent via email
#   Defaults to ['panic']
#
# [*log_hooks_mail_smtp_addr*]
#   Mail server address
#   Defaults to "smtp.${::domain}:25"
#
# [*log_hooks_mail_smtp_username*]
#   Mail server login username
#
# [*log_hooks_mail_smtp_password*]
#   Mail server login password
#
# [*log_hooks_mail_smtp_insecure*]
#   Use insecure smtp
#
# [*log_hooks_mail_from*]
#   Mail sender
#
# [*log_hooks_mail_to*]
#   Mail recepients
#
# [*storage_type*]
#   Where does docker registry keep the images
#   One of filesystem, azure, gcs, s3, rados, swift
#   Defauts to filesystem
#
# [*filesystem_rootdirectory*]
#   The filesystem storage backend uses the local disk to store registry files.
#   It is ideal for development and may be appropriate for some small-scale production applications.
#   This backend has a single, required rootdirectory parameter. The parameter specifies the absolute
#   path to a directory. The registry stores all its data here so make sure there is adequate space available.
#
### This storage backend uses Microsoft's Azure Blob Storage. ###
# [*azure_accountname*]
#   Azure account name.
#
# [*azure_accountkey*]
#   Azure account key.
#
# [*azure_container*]
#   Name of the Azure container into which to store data.
#
# [*azure_realm*]
#   Domain name suffix for the Storage Service API endpoint.
#   By default, this is core.windows.net
#
### This storage backend uses Google Cloud Storage. ###
# [*gcs_bucket*]
#    Storage bucket name. 
#
# [*gcs_keyfile*]
#   A private service account key file in JSON format.
#   Instead of a key file Google Application Default Credentials can be used. 
#
# [*gcs_rootdirectory*]
#   This is a prefix that will be applied to all Google Cloud Storage keys
#   to allow you to segment data in your bucket if necessary. 
#
### This storage backend uses Amazon's Simple Storage Service (S3). ###
# [*s3_accesskey*]
#    Your AWS Access Key. 
#
# [*s3_secretkey*]
#    Your AWS Secret Key. 
#
# [*s3_region*]
#   The AWS region in which your bucket exists. For the moment, the Go AWS library
#   in use does not use the newer DNS based bucket routing. 
#
# [*s3_bucket*]
#    The bucket name in which you want to store the registry's data. 
#
# [*s3_encrypt*]
#   Specifies whether the registry stores the image in encrypted format or not. A boolean value. The default is false. 
#
# [*s3_secure*]
#   Indicates whether to use HTTPS instead of HTTP. A boolean value. The default is true. 
#
# [*s3_v4auth*]
#   Indicates whether the registry uses Version 4 of AWS's authentication.
#   Generally, you should set this to true. By default, this is false. 
#
# [*s3_chunksize*]
#   The S3 API requires multipart upload chunks to be at least 5MB. This value should be a number that is larger than 5*1024*1024. 
#
# [*s3_rootdirectory*]
#   This is a prefix that will be applied to all S3 keys to allow you to segment data in your bucket if necessary. 
#
### This storage backend uses Ceph Object Storage. ###
# [*rados_poolname*]
#   Ceph pool name.
#
# [*rados_username*]
#    Ceph cluster user to connect as (i.e. admin, not client.admin). 
#
# [*rados_chunksize*]
#    Size of the written RADOS objects. Default value is 4MB (4194304). 
#
### This storage backend uses Openstack Swift object storage. ###
# [*swift_username*]
#    Your Openstack user name. 
#
# [*swift_password*]
#    Your Openstack password. 
#
# [*swift_authurl*]
#   URL for obtaining an auth token. https://storage.myprovider.com/v2.0 or https://storage.myprovider.com/v3/auth
#
# [*swift_tenant*]
#    Your Openstack tenant name. 
#
# [*swift_tenantid*]
#    Your Openstack tenant id. 
#
# [*swift_domain*]
#    Your Openstack domain name for Identity v3 API. 
#
# [*swift_domainid*]
#    Your Openstack domain id for Identity v3 API. 
#
# [*swift_insecureskipverify*]
#    true to skip TLS verification, false by default. 
#
# [*swift_region*]
#    The Openstack region in which your container exists. 
#
# [*swift_container*]
#    The container name in which you want to store the registry's data. 
#
# [*swift_rootdirectory*]
#   This is a prefix that will be applied to all Swift keys to allow you to segment data in your container if necessary. 
#
# [*swift_trustid*]
#    Your Openstack trust id for Identity v3 API. 
#
# [*swift_chunksize*]
#    Size of the data segments for the Swift Dynamic Large Objects. This value should be a number (defaults to 5M). 
#
####
# [*storage_delete*]
#   Use the delete subsection to enable the deletion of image blobs and manifests by digest.
#   It defaults to false
#
# [*storage_redirect*]
#   The redirect subsection provides configuration for managing redirects from content backends.
#   For backends that support it, redirecting is enabled by default. Certain deployment scenarios
#   may prefer to route all data through the Registry, rather than redirecting to the backend.
#   This may be more efficient when using a backend that is not colocated or when a registry instance is doing aggressive caching.
#   Defaults to undef
#
# [*storage_cache_blobdescriptor*]
#   Use the cache subsection to enable caching of data accessed in the storage backend.
#   Currently, the only available cache provides fast access to layer metadata.
#   This, if configured, uses the blobdescriptor field.
#   You can set blobdescriptor field to redis or inmemory. The redis value uses a Redis pool to cache layer metadata.
#   The inmemory value uses an in memory map.
#   Defaults to inmemory
#
# [*auth_type*]
#   One of token and htpasswd
#
### Token based authentication allows the authentication system to be decoupled from the registry. ###
### It is a well established authentication paradigm with a high degree of security. ###
# [*auth_token_realm*]
#    The realm in which the registry server authenticates. 
#
# [*auth_token_service*]
#    The service being authenticated. 
#
# [*auth_token_issuer*]
#   The name of the token issuer. The issuer inserts this into the token so it must match the value configured for the issuer. 
#
# [*auth_token_rootcertbundle*]
#   The absolute path to the root certificate bundle. This bundle contains the public part of the certificates that is used to sign authentication tokens. 
#
### The htpasswd authentication backed allows one to configure basic auth using an Apache HTPasswd File. ###
### Only bcrypt format passwords are supported. Entries with other hash types will be ignored. ###
### The htpasswd file is loaded once, at startup. If the file is invalid, the registry will display and error and will not start. ###
# [*auth_htpasswd_realm*]
#    The realm in which the registry server authenticates. 
#
# [*auth_htpasswd_path*]
#    Path to htpasswd file to load at startup. 
#
# [*http_addr*]
#   The address for which the server should accept connections. The form depends on a network type (see net option): HOST:PORT for tcp and FILE for a unix socket. 
#
# [*http_net*]
#   The network which is used to create a listening socket. Known networks are unix and tcp.
#   The default empty value means tcp. 
#
# [*http_prefix*]
#   If the server does not run at the root path use this value to specify the prefix.
#   The root path is the section before v2. It should have both preceding and trailing slashes, for example /path/
#
# [*http_host*]
#   This parameter specifies an externally-reachable address for the registry, as a fully qualified URL.
#   If present, it is used when creating generated URLs. Otherwise, these URLs are derived from client requests. 
#
# [*http_secret*]
#   A random piece of data. This is used to sign state that may be stored with the client to protect against tampering.
#   For production environments you should generate a random piece of data using a cryptographically secure random generator.
#   This configuration parameter may be omitted, in which case the registry will automatically generate a secret at launch.
#   WARNING: If you are building a cluster of registries behind a load balancer, you MUST ensure the secret is the same for all registries. 
#
# [*http_tls*]
#   Use this to configure TLS for the server.
#
# [*http_tls_certificate*]
#    Absolute path to x509 cert file 
#
# [*http_tls_key*]
#    Absolute path to x509 private key file. 
#
# [*http_tls_clientcas*]
#    An array of absolute paths to a x509 CA file 
#
# [*http_debug_addr*]
#   The debug option is optional . Use it to configure a debug server that can be helpful in diagnosing problems.
#   The debug endpoint can be used for monitoring registry metrics and health, as well as profiling.
#   Sensitive information may be available via the debug endpoint.
#   Please be certain that access to the debug endpoint is locked down in a production environment.
#   This parameter specifies the HOST:PORT on which the debug server should accept connections.
#
# [*http_headers*]
#   The headers option is optional. Use it to specify headers that the HTTP server should include in responses.
#   This can be used for security headers such as Strict-Transport-Security.
#   The headers option should contain an option for each header to include, where the parameter name is the header's name,
#   and the parameter value a list of the header's payload values.
#   Including X-Content-Type-Options: [nosniff] is recommended, so that browsers will not interpret content as HTML
#   if they are directed to load a page from the registry. This header is included in the example configuration files.
#
#
# [*notifications_name*]
#    A human readable name for the service. 
#
# [*notifications_disabled*]
#    A boolean to enable/disable notifications for a service. 
#
# [*notifications_url*]
#    The URL to which events should be published. 
#
# [*notifications_headers*]
#    Static headers to add to each request. Each header's name should be a key underneath headers, and each value is a list
#    of payloads for that header name. Note that values must always be lists. 
#
# [*notifications_timeout*]
#    An HTTP timeout value. This field takes a positive integer and an optional suffix indicating the unit of time.
#
# [*notifications_threshold*]
#    An integer specifying how long to wait before backing off a failure. 
#
# [*notifications_backoff*]
#    How long the system backs off before retrying. This field takes a positive integer and an optional suffix indicating the unit of time.
#
# [*redis_addr*]
#    Address (host and port) of redis instance. 
#
# [*redis_password*]
#    A password used to authenticate to the redis instance. 
#
# [*redis_db*]
#    Selects the db for each connection. 
#
# [*redis_dialtimeout*]
#    Timeout for connecting to a redis instance. 
#
# [*redis_readtimeout*]
#    Timeout for reading from redis connections. 
#
# [*redis_writetimeout*]
#    Timeout for writing to redis connections. 
#
# [*redis_pool_maxidle*]
#    Sets the maximum number of idle connections. 
#
# [*redis_pool_maxactive*]
#   sets the maximum number of connections that should be opened before blocking a connection request. 
#
# [*redis_pool_idletimeout*]
#    sets the amount time to wait before closing inactive connections. 
#
### Proxy enables a registry to be configured as a pull through cache to the official Docker Hub. ###
# [*proxy_remoteurl*]
#    The URL of the official Docker Hub 
#
# [*proxy_username*]
#    The username of the Docker Hub account 
#
# [*proxy_password*]
#    The password for the official Docker Hub account 
#
class docker_distribution (
  $manage_as                    = $::docker_distribution::params::manage_as,
  $container_image              = $::docker_distribution::params::container_image,
  $package_name                 = $::docker_distribution::params::package_name,
  $package_ensure               = $::docker_distribution::params::package_ensure,
  $service_name                 = $::docker_distribution::params::service_name,
  $service_ensure               = $::docker_distribution::params::service_ensure,
  $service_enable               = $::docker_distribution::params::service_enable,
  $journald_forward_enable      = $::docker_distribution::params::journald_forward_enable,
  $mount_global_ca              = $::docker_distribution::params::mount_global_ca,
  $log_level                    = $::docker_distribution::params::log_level,
  $log_formatter                = $::docker_distribution::params::log_formatter,
  $log_fields                   = $::docker_distribution::params::log_fields,
  $log_hooks_mail_disabled      = $::docker_distribution::params::log_hooks_mail_disabled,
  $log_hooks_mail_levels        = $::docker_distribution::params::log_hooks_mail_levels,
  $log_hooks_mail_smtp_addr     = $::docker_distribution::params::log_hooks_mail_smtp_addr,
  $log_hooks_mail_smtp_username = $::docker_distribution::params::log_hooks_mail_smtp_username,
  $log_hooks_mail_smtp_password = $::docker_distribution::params::log_hooks_mail_smtp_password,
  $log_hooks_mail_smtp_insecure = $::docker_distribution::params::log_hooks_mail_smtp_insecure,
  $log_hooks_mail_from          = $::docker_distribution::params::log_hooks_mail_from,
  $log_hooks_mail_to            = $::docker_distribution::params::log_hooks_mail_to,
  $storage_type                 = $::docker_distribution::params::storage_type,
  $filesystem_rootdirectory     = $::docker_distribution::params::filesystem_rootdirectory,
  $azure_accountname            = $::docker_distribution::params::azure_accountname,
  $azure_accountkey             = $::docker_distribution::params::azure_accountkey,
  $azure_container              = $::docker_distribution::params::azure_container,
  $azure_realm                  = $::docker_distribution::params::azure_realm,
  $gcs_bucket                   = $::docker_distribution::params::gcs_bucket,
  $gcs_keyfile                  = $::docker_distribution::params::gcs_keyfile,
  $gcs_rootdirectory            = $::docker_distribution::params::gcs_rootdirectory,
  $s3_accesskey                 = $::docker_distribution::params::s3_accesskey,
  $s3_secretkey                 = $::docker_distribution::params::s3_secretkey,
  $s3_region                    = $::docker_distribution::params::s3_region,
  $s3_bucket                    = $::docker_distribution::params::s3_bucket,
  $s3_encrypt                   = $::docker_distribution::params::s3_encrypt,
  $s3_secure                    = $::docker_distribution::params::s3_secure,
  $s3_v4auth                    = $::docker_distribution::params::s3_v4auth,
  $s3_chunksize                 = $::docker_distribution::params::s3_chunksize,
  $s3_rootdirectory             = $::docker_distribution::params::s3_rootdirectory,
  $rados_poolname               = $::docker_distribution::params::rados_poolname,
  $rados_username               = $::docker_distribution::params::rados_username,
  $rados_chunksize              = $::docker_distribution::params::rados_chunksize,
  $swift_username               = $::docker_distribution::params::swift_username,
  $swift_password               = $::docker_distribution::params::swift_password,
  $swift_authurl                = $::docker_distribution::params::swift_authurl,
  $swift_tenant                 = $::docker_distribution::params::swift_tenant,
  $swift_tenantid               = $::docker_distribution::params::swift_tenantid,
  $swift_domain                 = $::docker_distribution::params::swift_domain,
  $swift_domainid               = $::docker_distribution::params::swift_domainid,
  $swift_insecureskipverify     = $::docker_distribution::params::swift_insecureskipverify,
  $swift_region                 = $::docker_distribution::params::swift_region,
  $swift_container              = $::docker_distribution::params::swift_container,
  $swift_rootdirectory          = $::docker_distribution::params::swift_rootdirectory,
  $swift_trustid                = $::docker_distribution::params::swift_trustid,
  $swift_chunksize              = $::docker_distribution::params::swift_chunksize,
  $storage_delete               = $::docker_distribution::params::storage_delete,
  $storage_redirect             = $::docker_distribution::params::storage_redirect,
  $storage_cache_blobdescriptor = $::docker_distribution::params::storage_cache_blobdescriptor,
  $auth_type                    = $::docker_distribution::params::auth_type,
  $auth_token_realm             = $::docker_distribution::params::auth_token_realm,
  $auth_token_service           = $::docker_distribution::params::auth_token_service,
  $auth_token_issuer            = $::docker_distribution::params::auth_token_issuer,
  $auth_token_rootcertbundle    = $::docker_distribution::params::auth_token_rootcertbundle,
  $auth_htpasswd_realm          = $::docker_distribution::params::auth_htpasswd_realm,
  $auth_htpasswd_path           = $::docker_distribution::params::auth_htpasswd_path,
  $http_addr                    = $::docker_distribution::params::http_addr,
  $http_net                     = $::docker_distribution::params::http_net,
  $http_prefix                  = $::docker_distribution::params::http_prefix,
  $http_host                    = $::docker_distribution::params::http_host,
  $http_secret                  = $::docker_distribution::params::http_secret,
  $http_tls                     = $::docker_distribution::params::http_tls,
  $http_tls_certificate         = $::docker_distribution::params::http_tls_certificate,
  $http_tls_key                 = $::docker_distribution::params::http_tls_key,
  $http_tls_clientcas           = $::docker_distribution::params::http_tls_clientcas,
  $http_debug_addr              = $::docker_distribution::params::http_debug_addr,
  $http_headers                 = $::docker_distribution::params::http_headers,
  $notifications_name           = $::docker_distribution::params::notifications_name,
  $notifications_disabled       = $::docker_distribution::params::notifications_disabled,
  $notifications_url            = $::docker_distribution::params::notifications_url,
  $notifications_headers        = $::docker_distribution::params::notifications_headers,
  $notifications_timeout        = $::docker_distribution::params::notifications_timeout,
  $notifications_threshold      = $::docker_distribution::params::notifications_threshold,
  $notifications_backoff        = $::docker_distribution::params::notifications_backoff,
  $redis_addr                   = $::docker_distribution::params::redis_addr,
  $redis_password               = $::docker_distribution::params::redis_password,
  $redis_db                     = $::docker_distribution::params::redis_db,
  $redis_dialtimeout            = $::docker_distribution::params::redis_dialtimeout,
  $redis_readtimeout            = $::docker_distribution::params::redis_readtimeout,
  $redis_writetimeout           = $::docker_distribution::params::redis_writetimeout,
  $redis_pool_maxidle           = $::docker_distribution::params::redis_pool_maxidle,
  $redis_pool_maxactive         = $::docker_distribution::params::redis_pool_maxactive,
  $redis_pool_idletimeout       = $::docker_distribution::params::redis_pool_idletimeout,
  $proxy_remoteurl              = $::docker_distribution::params::proxy_remoteurl,
  $proxy_username               = $::docker_distribution::params::proxy_username,
  $proxy_password               = $::docker_distribution::params::proxy_password,
) inherits docker_distribution::params {
  validate_re($manage_as, '^(service|container)$')
  validate_bool($log_hooks_mail_disabled, $storage_delete, $storage_redirect, $journald_forward_enable)
  if !$log_hooks_mail_disabled and empty($log_hooks_mail_to) {fail("log_hooks_mail_to parameter can't be empty")}
  validate_re($log_level, '^(error|warn|info|debug)$')
  validate_re($log_formatter, '^(text|json|logstash)$')
  validate_re($storage_type, '^(filesystem|azure|gcs|s3|rados|swift)$')
  validate_re($storage_cache_blobdescriptor, '^(redis|inmemory)$')
  if $auth_type {validate_re($auth_type, '^(token|htpasswd)$')}

  contain ::docker_distribution::install
  contain ::docker_distribution::config
  contain ::docker_distribution::service

  Class['::docker_distribution::install'] ->
  Class['::docker_distribution::config'] ~>
  Class['::docker_distribution::service']
}
