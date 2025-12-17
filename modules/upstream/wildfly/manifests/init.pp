#
# Main class, includes all other classes.
#
# @param config Sets Wildfly configuration file for initialization when you're using 'standalone' mode.
# @param conf_file Sets a file to be used for service configuration.
# @param conf_template Sets a template file for service configuration.
# @param console_log Configures service log file.
# @param custom_init Sets a custom init script.
# @param distribution Sets the Wildfly distribution: 'wildfly' or 'jboss-eap'.
# @param dirname `JBOSS_HOME`. i.e. The directory where your Wildfly will live.
# @param domain_config Sets Wildfly configuration file for initialization when you're using 'domain' mode.
# @param external_facts Whether it should deploy external facts.
# @param gid Sets managed group ID.
# @param group Group to own `JBOSS_HOME`. If `manage_user` is `true`, this group will be managed.
# @param host_config Sets Wildfly Host configuration file for initialization when you're using 'domain' mode.
# @param install_cache_dir The directory to be used for wget cache.
# @param deploy_cache_dir The directory to be used for deployment cache.
# @param install_download_timeout Sets the timeout for installer download.
# @param install_source Custom source of Wildfly tarball installer. Defaults to standard Wildfly repositories.
# @param java_home Sets the `JAVA_HOME` for Wildfly.
# @param java_opts Sets `JAVA_OPTS`, allowing to override several Java params, like `Xmx`, `Xms` and `MaxMetaspaceSize`,
# @param java_xmx Sets Java's `-Xmx` parameter.
# @param java_xms Sets Java's `-Xms` parameter.
# @param java_maxmetaspace_size Sets Java's `-XX:MaxMetaspaceSize` parameter.
# @param jboss_opts Sets `JBOSS_OPTS`, allowing to override several JBoss properties. It only works with Wildfly 8.2+.
# @param manage_user Whether this module should manage wildfly user and group.
# @param mgmt_user Hash containing a Wildfly's management user to be used internally.
# @param mgmt_create_keystores Enables or disables the creation of keystores for TLS enabled ManagementRealm.
# @param mgmt_keystore Path to a pre-defined keystore to be used for a TLS enabled ManagementRealm.
# @param mgmt_keystore_alias The java keystore 'alias' to be used for a TLS enabled ManagementRealm.
# @param mgmt_keystore_pass The java keystore password to be used for a TLS enabled ManagementRealm.
# @param mgmt_ssl_cert Path to the certificate used for setting up the ManagementRealm keystore.
# @param mgmt_ssl_key Path to the private key used for setting up the ManagementRealm keystore.
# @param mode Sets Wildfly execution mode will run, 'standalone' or 'domain'.
# @param mode_template Sets epp template for standalone.conf or domain.conf.
# @param overlay_class Sets a class to be applied between 'install' and 'setup' classes.
# @param package_ensure Wheter it should manage required packages.
# @param package_name Sets Wildfly package name.
# @param package_version Sets Wildfly package version.
# @param properties Sets properties for your service.
# @param remote_debug Whether remote debug should be enabled.
# @param remote_debug_port Sets the port to be used by remote debug.
# @param remote_username Sets remote username in host config.
# @param secret_value Sets the secret value in host config.
# @param secure_mgmt_api Setup and use HTTPS calls to the management API.
# @param service_ensure Sets Wildfly's service 'ensure'.
# @param service_enable Sets Wildfly's service 'enable'.
# @param service_file Sets a file to be used for service management.
# @param service_name Sets Wildfly's service 'name'.
# @param service_manage Reload Wildfly's service when changed config.
# @param shutdown_wait Sets the time to wait for the process to be shutdown - sysvinit scripts only.
# @param startup_wait Sets the time to wait for the process to be up - sysvinit scripts only.
# @param systemd_template Sets a custom systemd template.
# @param uid Sets managed user ID.
# @param user User to own `JBOSS_HOME`. If `manage_user` is `true`, this user will be managed.
# @param user_home User home directory. Defaults to '/home/wildfly'
# @param version Sets the Wildfly version managed in order to handle small differences among versions.
#
class wildfly (
  Pattern[/^(\d{1,}\.\d{1,}(\.\d{1,})?$)/]           $version                      = '9.0.2',
  Variant[Pattern[/^file:\/\//],
    Pattern[/^puppet:\/\//],
    Stdlib::Httpsurl, Stdlib::Httpurl,
    Undef
  ]                                                  $install_source               = undef,
  Wildfly::Distribution                              $distribution                 = 'wildfly',
  Wildfly::Mode                                      $mode                         = 'standalone',
  Stdlib::Unixpath                                   $dirname                      = '/opt/wildfly',
  Stdlib::Unixpath                                   $java_home                    = '/usr/java/default',
  Stdlib::Unixpath                                   $console_log                  = '/var/log/wildfly/console.log',
  Stdlib::Unixpath                                   $install_cache_dir            = '/var/cache/wget',
  Stdlib::Unixpath                                   $deploy_cache_dir             = '/opt',
  Stdlib::Unixpath                                   $mgmt_keystore                = "${dirname}/${mode}/configuration/mgmt.jks",
  Boolean                                            $manage_user                  = true,
  String                                             $user                         = 'wildfly',
  Stdlib::Unixpath                                   $user_home                    = '/home/wildfly',
  String                                             $group                        = 'wildfly',
  String                                             $mode_template                = "wildfly/${mode}.conf",
  String                                             $mgmt_keystore_pass           = 'changeit',
  String                                             $mgmt_keystore_alias          = 'mgmt',
  Wildfly::Config_file                               $config                       = 'standalone.xml',
  Wildfly::Config_file                               $domain_config                = 'domain.xml',
  Wildfly::Config_file                               $host_config                  = 'host.xml',
  String                                             $java_xmx                     = '512m',
  String                                             $java_xms                     = '256m',
  String                                             $java_maxmetaspace_size       = '128m',
  String                                             $package_ensure               = 'present',
  Boolean                                            $service_ensure               = true,
  Boolean                                            $service_manage               = true,
  Boolean                                            $service_enable               = true,
  Boolean                                            $remote_debug                 = false,
  Boolean                                            $external_facts               = false,
  Boolean                                            $secure_mgmt_api              = false,
  Boolean                                            $mgmt_create_keystores        = true,
  Integer                                            $remote_debug_port            = 8787,
  Integer                                            $startup_wait                 = 30,
  Integer                                            $shutdown_wait                = 30,
  Integer                                            $install_download_timeout     = 500,
  Hash[Pattern[/^\w*(\.\w*-?\w*)*$/], String]        $properties                   = {
    'jboss.bind.address' => '0.0.0.0',
    'jboss.bind.address.management' => '127.0.0.1',
    'jboss.management.http.port' => '9990',
    'jboss.management.https.port' => '9993',
    'jboss.http.port' => '8080',
    'jboss.https.port' => '8443',
    'jboss.ajp.port' => '8009',
  },
  Struct[{ username => String, password => String }] $mgmt_user                    = {
    username => 'puppet',
    password => fqdn_rand_string(30),
  },
  Optional[Stdlib::Unixpath]                         $conf_file                    = undef,
  Optional[String]                                   $conf_template                = undef,
  Optional[Stdlib::Unixpath]                         $service_file                 = undef,
  Optional[String]                                   $systemd_template             = undef,
  Optional[String]                                   $service_name                 = undef,
  Optional[String]                                   $custom_init                  = undef,
  Optional[Integer]                                  $uid                          = undef,
  Optional[Integer]                                  $gid                          = undef,
  Optional[String]                                   $secret_value                 = undef,
  Optional[String]                                   $remote_username              = undef,
  Optional[String]                                   $package_name                 = undef,
  Optional[String]                                   $package_version              = undef,
  Variant[Undef, String, Array]                      $java_opts                    = undef,
  Variant[Undef, String, Array]                      $process_controller_java_opts = undef,
  Variant[Undef, String, Array]                      $host_controller_java_opts    = undef,
  Optional[String]                                   $jboss_opts                   = undef,
  Optional[String]                                   $overlay_class                = undef,
  Optional[Stdlib::Unixpath]                         $mgmt_ssl_cert                = undef,
  Optional[Stdlib::Unixpath]                         $mgmt_ssl_key                 = undef,
) {
  contain wildfly::prepare
  contain wildfly::install
  contain wildfly::setup
  contain wildfly::service

  if $overlay_class {
    contain $overlay_class

    Class['wildfly::install']
    -> Class[$overlay_class]
    -> Class['wildfly::setup']
  }

  if $external_facts {
    contain wildfly::external_facts

    Class['wildfly::external_facts']
    -> Class['wildfly::install']
  }

  if $secure_mgmt_api {
    include wildfly::secure_mgmt_api
  }

  Class['wildfly::prepare']
  -> Class['wildfly::install']
  -> Class['wildfly::setup']
  -> Class['wildfly::service']
}
