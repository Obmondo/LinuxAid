# Rsyslog Server
class profile::collector::rsyslog {

  class { '::rsyslog::server':
    global_config      => {},
    legacy_config      => {},
    templates          => {},
    actions            => {},
    inputs             => {},
    custom_config      => {},
    main_queue_opts    => {},
    modules            => {},
    lookup_tables      => {},
    parsers            => {},
    rulesets           => {},
    property_filters   => {},
    expression_filters => {},
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
