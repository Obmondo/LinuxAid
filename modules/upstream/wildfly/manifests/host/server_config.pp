#
# Manages a host server-config.
#
define wildfly::host::server_config($config) {

  wildfly::resource { "/host=${::hostname}/server-config=${title}":
    content => $config,
  }
}
