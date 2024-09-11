# haproxy backend down alert
class monitor::service::haproxy::backend_down (
  Boolean       $enable          = true,
  Array[String] $ignore_backends = [],
) inherits monitor::service::haproxy {

  @@monitor::alert { 'monitor::service::haproxy::backend_down':
    enable => $enable,
    tag    => $::trusted['certname'],

  }

  $ignore_backends.each |$backend| {
    @@monitor::threshold { "haproxy backend ${backend}":
      record => "${name}::ignore_backend",
      tag    => $::trusted['certname'],
      expr   => 1,
      labels => {
        proxy => $backend,
      }
    }
  }
}
