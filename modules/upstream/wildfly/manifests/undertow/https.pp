#
# Configures a connector
#
define wildfly::undertow::https(
  $socket_binding = undef,
  $keystore_path = undef,
  $keystore_relative_to = undef,
  $keystore_password = undef,
  $key_alias = undef,
  $key_password = undef,
  $target_profile = undef,
  $enabled_protocols = undef,
  $enabled_cipher_suites = undef) {

  if versioncmp($wildfly::version,'9.0.0') >= 0 {
    # Wildfly 9 and higher -> we need to set enable parameter
    $listener_content = {
      'socket-binding'        => $socket_binding,
      'security-realm'        => 'TLSRealm',
      'enabled-protocols'     => $enabled_protocols,
      'enabled-cipher-suites' => $enabled_cipher_suites,
      'enabled'               => true,
    }
  } else {
    $listener_content = {
      'socket-binding'        => $socket_binding,
      'security-realm'        => 'TLSRealm',
      'enabled-protocols'     => $enabled_protocols,
      'enabled-cipher-suites' => $enabled_cipher_suites,
    }
  }

  wildfly::resource { '/core-service=management/security-realm=TLSRealm':
    content => {},
  }
  ->
  wildfly::resource { '/core-service=management/security-realm=TLSRealm/server-identity=ssl':
    content => {
      'keystore-path'        => $keystore_path,
      'keystore-relative-to' => $keystore_relative_to,
      'keystore-password'    => $keystore_password,
      'alias'                => $key_alias,
      'key-password'         => $key_password
    },
  }
  ->
  wildfly::resource { "/subsystem=undertow/server=default-server/https-listener=${title}":
    content => $listener_content,
    profile => $target_profile,
  }

}
