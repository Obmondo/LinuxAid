# Haproxy web role
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
  Hash[Eit_types::IP,Variant[
    Array[Stdlib::Port],
    Stdlib::Port
  ]]                            $firewall               = {},
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
