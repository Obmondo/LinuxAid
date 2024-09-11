# service down
class monitor::system::service::down (
  Boolean       $enable    = true,
  Array[String] $blacklist = [],

  Monitor::Disable  $disable  = undef,
  Monitor::Override $override = undef,
) {

  @@monitor::alert { $name:
    enable  => $enable,
    disable => $disable,
    tag     => $::trusted['certname'],
  }

  $blacklist.each |$_service| {
    $_service_name = if $_service.match(/\.service$/) {
      $_service
    } else {
      "${_service}.service"
    }

    @@monitor::threshold { "${name}::blacklist::${_service_name}":
      record   => "${name}::blacklist",
      expr     => 1,
      override => $override,
      tag      => $::trusted['certname'],
      labels   => {
        'name' => $_service_name,
      }
    }
  }
}
