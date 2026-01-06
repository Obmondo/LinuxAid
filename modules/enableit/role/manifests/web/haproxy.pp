
# @summary Class for managing the Haproxy web role
#
# @param manual_config Optional manual configuration for the haproxy. Defaults to undef.
#
# @param domains The domains to be managed by haproxy. Defaults to an empty hash.
#
# @param listens The listening configurations for haproxy. Defaults to an empty hash.
#
# @param ddos_protection Boolean to enable or disable DDoS protection. Defaults to false.
#
# @param https Boolean to enable or disable HTTPS. Defaults to true.
#
# @param http Boolean to enable or disable HTTP. Defaults to false.
#
# @param use_hsts Boolean to enable or disable HSTS. Defaults to true.
#
# @param use_lets_encrypt Boolean to enable or disable Let's Encrypt. Defaults to true.
#
# @param mode The mode of haproxy. Defaults to 'http'.
#
# @param listen_on The IP addresses for haproxy to listen on. Defaults to ['0.0.0.0'].
#
# @param encryption_ciphers The encryption ciphers to use. Defaults to 'Modern'.
#
# @param configure The configuration method to use. Defaults to 'auto'.
#
# @param firewall The firewall configurations. Defaults to an empty hash.
#
# @param version The version of haproxy. Defaults to 'present'.
#
# @param service_options Additional options for the haproxy service. Defaults to an empty hash.
#
# @param log_compressed Boolean to enable or disable compressed logs. Defaults to true.
#
# @param log_dir The directory for log files. Defaults to '/var/log'.
#
# @param $__blendable 
# Boolean to indicate if blending is enabled.
#
# @param send_log_summary Boolean to enable or disable sending log summaries. Defaults to false.
#
# @param log_summary_recipients The recipients for log summaries. Defaults to ['info@enableit.dk'].
#
# @groups security ddos_protection, https, use_hsts, use_lets_encrypt, encryption_ciphers
#
# @groups configuration manual_config, configure, service_options, version
#
# @groups networking domains, listens, listen_on, firewall
#
# @groups logging log_compressed, log_dir, send_log_summary, log_summary_recipients
#
# @groups mode mode, http
#
class role::web::haproxy (
  Optional[String]              $manual_config          = undef,
  Eit_haproxy::Domains          $domains                = {},
  Eit_haproxy::Listen           $listens                = {},
  Boolean                       $ddos_protection        = false,
  Boolean                       $https                  = true,
  Boolean                       $http                   = false,
  Boolean                       $use_hsts               = true,
  Boolean                       $use_lets_encrypt       = true,
  Enum['tcp', 'http']           $mode                   = 'http',
  Array[Stdlib::IP::Address,1]  $listen_on              = ['0.0.0.0'],
  Enum['Modern','Intermediate'] $encryption_ciphers     = 'Modern',
  Enum['auto', 'manual']        $configure              = 'auto',
  Hash[Eit_types::IP,Variant[    Array[Stdlib::Port],    Stdlib::Port  ]]                            $firewall               = {},
  Eit_types::Package_version    $version                = 'present',
  Hash                          $service_options        = {},
  Boolean                       $log_compressed         = true,
  Stdlib::Absolutepath          $log_dir                = '/var/log',
  Boolean                       $__blendable,
  Boolean                       $send_log_summary       = false,
  Array[String]                 $log_summary_recipients = ['info@enableit.dk'],
) inherits role::web {

  confine($configure == 'manual', !$manual_config, 'Manual configuration need static haproxy config file')
  confine($send_log_summary, $log_summary_recipients.size == 0, 'Log summary sender needs at least 1 recipient')

  class { 'profile::haproxy':
    domains                => $domains,
    listens                => $listens,
    ddos_protection        => $ddos_protection,
    https                  => $https,
    http                   => $http,
    use_hsts               => $use_hsts,
    use_lets_encrypt       => $use_lets_encrypt,
    mode                   => $mode,
    manual_config          => $manual_config,
    version                => $version,
    configure              => $configure,
    listen_on              => $listen_on,
    encryption_ciphers     => $encryption_ciphers,
    firewall               => $firewall,
    service_options        => $service_options,
    log_compressed         => $log_compressed,
    log_dir                => $log_dir,
    send_log_summary       => $send_log_summary,
    log_summary_recipients => $log_summary_recipients,
  }
}
