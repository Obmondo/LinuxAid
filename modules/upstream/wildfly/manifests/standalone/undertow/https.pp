#
# Configures a connector
#
define wildfly::standalone::undertow::https($socket_binding = undef, $keystore_path = undef, $keystore_password = undef, $key_alias = undef, $key_password = undef) {

  wildfly::util::resource { '/core-service=management/security-realm=TLSRealm':
    content => { }
  }
  ->
  wildfly::util::resource { '/core-service=management/security-realm=TLSRealm/server-identity=ssl':
    content => {
      'keystore-path'     => $keystore_path,
      'keystore-password' => $keystore_password,
      'alias'             => $key_alias,
      'key-password'      => $key_password
    }
  }
  ->
  wildfly::util::resource { "/subsystem=undertow/server=default-server/https-listener=${name}":
    content => {
      'socket-binding' => $socket_binding,
      'security-realm' => 'TLSRealm'
    }
  }

}