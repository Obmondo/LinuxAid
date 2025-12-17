#
# Manages a domain server group.
#
# @param ensure Whether the resource should exist (`present`) or not (`absent`).
# @param profile Sets profile referenced by the server-group.
# @param socket_binding_group Sets socket-binding-group referenced by the server-group.
# @param socket_binding_port_offset Sets socket-binding-port-offset server-config port offset.
# @param jvm_name Sets jvm name configured to the server-group.
# @param jvm_config Sets jvm configurations like ``, `` etc.
define wildfly::domain::server_group (
  Enum[present, absent] $ensure                     = present,
  Integer               $socket_binding_port_offset = 0,
  String                $jvm_name                   = 'default',
  Hash                  $jvm_config                 = {},
  Optional[String]      $profile                    = undef,
  Optional[String]      $socket_binding_group       = undef,
) {
  require wildfly::install

  $server_group_name = $title

  if $ensure == present {
    if empty($profile) {
      fail('profile is required')
    }

    if empty($socket_binding_group) {
      fail('socket_binding_group is required')
    }

    wildfly::resource { "/server-group=${server_group_name}":
      content => {
        'profile'                    => $profile,
        'socket-binding-group'       => $socket_binding_group,
        'socket-binding-port-offset' => $socket_binding_port_offset,
      },
    }
    -> wildfly::resource { "/server-group=${server_group_name}/jvm=${jvm_name}" :
      content => $jvm_config,
    }
  } elsif $ensure == absent {
    wildfly::resource { "/server-group=${server_group_name}" :
      ensure => absent,
    }
  }
}
