# Rsyslog Server
class profile::rsyslog (
  Optional[Hash] $global_config      = {},
  Optional[Hash] $legacy_config      = {},
  Optional[Hash] $templates          = {},
  Optional[Hash] $actions            = {},
  Optional[Hash] $inputs             = {},
  Optional[Hash] $custom_config      = {},
  Optional[Hash] $main_queue_opts    = {},
  Optional[Hash] $modules            = {},
  Optional[Hash] $lookup_tables      = {},
  Optional[Hash] $parsers            = {},
  Optional[Hash] $rulesets           = {},
  Hash           $property_filters   = {},
  Hash           $expression_filters = {},
) {

  class { '::rsyslog::server':
    global_config      => $global_config,
    legacy_config      => $legacy_config,
    templates          => $templates,
    actions            => $actions,
    inputs             => $inputs,
    custom_config      => $custom_config,
    main_queue_opts    => $main_queue_opts,
    modules            => $modules,
    lookup_tables      => $lookup_tables,
    parsers            => $parsers,
    rulesets           => $rulesets,
    property_filters   => $property_filters,
    expression_filters => $expression_filters,
  }


  firewall_multi { '200 allow rsyslog tcp,udp 514':
    ensure => 'present',
    proto  => [
      'tcp',
      'udp',
    ],
    jump   => 'accept',
    dport  => 514,
  }

}
