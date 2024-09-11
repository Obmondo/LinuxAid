define rsyslog::component::global_config (
  Integer $priority,
  String $target,
  String $confdir,
  Optional[String[1]] $value = undef,
  Hash $config = {},
  String[1] $type = 'rainerscript',
  String[1] $format = '<%= $content %>'
) {
  include rsyslog

  if $type == 'legacy' {
    $content = epp('rsyslog/global_config.epp', {
        'config_item' => $name,
        'type'        => $type,
        'value'       => $value
    })
  } else {
    $content = epp('rsyslog/global_config', {
        'type'   => $type,
        'config' => $config,
    })
  }

  rsyslog::generate_concat { "rsyslog::concat::global_config::${name}":
    confdir => $confdir,
    target  => $target,
    before  => Concat::Fragment["rsyslog::component::global_config::${name}"],
  }

  concat::fragment { "rsyslog::component::global_config::${name}":
    target  => "${confdir}/${target}",
    content => inline_epp($format),
    order   => $priority,
  }
}
