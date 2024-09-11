define rsyslog::component::lookup_table (
  Integer $priority,
  String $target,
  String $confdir,
  Hash $lookup_json,
  Stdlib::AbsolutePath $lookup_file,
  Boolean $reload_on_hup,
  Boolean $rsyslog_in_docker = false,
  Optional[Stdlib::AbsolutePath] $json_file = undef,
  String[1] $format = '<%= $content %>'
) {
  include rsyslog

  if $rsyslog_in_docker {
    $_json_file = $json_file
  } else {
    $_json_file = $lookup_file
  }

  file { "rsyslog::component::lookup_table_json::${title}":
    path    => $_json_file,
    content => inline_template('<%= JSON.pretty_generate @lookup_json %>'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $content = epp('rsyslog/lookup_table.epp', {
      'lookup_table_name' => $name,
      'file'              => $lookup_file,
      'reload_on_hup'     => $reload_on_hup,
  })

  rsyslog::generate_concat { "rsyslog::concat::lookup_table::${name}":
    confdir => $confdir,
    target  => $target,
    before  => Concat::Fragment["rsyslog::component::lookup_table::${name}"],
  }

  concat::fragment { "rsyslog::component::lookup_table::${name}":
    target  => "${confdir}/${target}",
    content => inline_epp($format),
    order   => $priority,
    require => File["rsyslog::component::lookup_table_json::${title}"],
  }
}
