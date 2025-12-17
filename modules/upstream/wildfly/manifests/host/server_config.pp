#
# Manages a host server-config. This defined type should be used at a slave machine (considering domain mode).
# You can use this resource to remove default servers server-one and server-two (present at default host-slave.xml).
# If you removed the default server-groups in the domain controller (main-server-group and other-server-group) you'll
# need to ensure that the resources are applied after the Wildfly installation and before the module starts to setup
# Wildfly to enable and run the service (or the host controller service will not run at all because the servers are
# associated to server-groups that doesn't exist).
# For this case, use a overlay_class (wildfly::overlay_class param) or the following snippet:
#
# wildfly::host::server_config { ['server-one', 'server-two']:
#   ensure   => absent,
#   hostname => $hostname,
#   username => $username,
#   password => $password,
#   require  => Class['wildfly::install'],
#   before   => Class['wildfly::setup'],
# }
#
# @param ensure Whether the resource should exist (`present`) or not (`absent`).
# @param server_group Sets server-group associated to server-config.
# @param offset Sets server-config port offset.
# @param auto_start Sets server to autostart with JBoss Service.
# @param wildfly_dir `JBOSS_HOME`. i.e. The directory where your Wildfly will live.
# @param host_config Sets Wildfly Host configuration file used for initialization in 'domain' mode.
# @param hostname Name used to identify host using JBoss CLI (/host=${hostname}).
# @param username Username to connect to domain controller.
# @param password Password to connect to domain controller.
# @param controller_address Domain controller address where the host will connect to configure the server-config.
# @param controller_mgmt_port Sets domain controller management port.
# @param start_server_after_created Sets if the server should be started right after created.
#
define wildfly::host::server_config (
  Enum[present, absent]          $ensure                     = present,
  Integer                        $offset                     = 0,
  Boolean                        $auto_start                 = true,
  Stdlib::Unixpath               $wildfly_dir                = $wildfly::dirname,
  Integer                        $controller_mgmt_port       = 9990,
  Boolean                        $start_server_after_created = true,
  Optional[Wildfly::Config_file] $host_config                = $wildfly::host_config,
  Optional[String]               $controller_address         = $wildfly::properties['jboss.domain.master.address'],
  Optional[String]               $server_group               = undef,
  Optional[String]               $hostname                   = undef,
  Optional[String]               $username                   = undef,
  Optional[String]               $password                   = undef,
) {
  require wildfly::install

  $server_name = $title

  if $ensure == present {
    if (!$server_group) {
      fail('server_group is required')
    }
  }

  $need_to_connect_to_domain_controller = ($ensure == present or $facts['wildfly_is_running'])

  if $need_to_connect_to_domain_controller {
    if (!$hostname) {
      fail('hostname is required')
    }

    if (!$username) {
      fail('username is required')
    }

    if (!$password) {
      fail('password is required')
    }

    if (!$controller_address) {
      fail('controller_address is required')
    }
  }

  if $ensure == present {
    debug("Will connect to domain controller to create server-config ${server_name}")

    wildfly_resource { "/host=${hostname}/server-config=${server_name}":
      state    => {
        'auto-start'                 => $auto_start,
        'group'                      => $server_group,
        'socket-binding-port-offset' => $offset,
      },
      username => $username,
      password => $password,
      host     => $controller_address,
      port     => $controller_mgmt_port,
      require  => Service['wildfly'],
    }

    if $start_server_after_created {
      debug("Will connect to domain controller to start server-config ${server_name}")

      wildfly_cli { "/host=${hostname}/server-config=${server_name}:start(blocking=true)":
        onlyif    => "(result != STARTED) of /host=${hostname}/server-config=${server_name}:read-attribute(name=status)",
        username  => $username,
        password  => $password,
        host      => $controller_address,
        port      => $controller_mgmt_port,
        subscribe => Wildfly_resource["/host=${hostname}/server-config=${server_name}"],
      }
    }
  } elsif $ensure == absent {
    debug("Wildfly is running? ${facts['wildfly_is_running']}")

    if (!$wildfly_dir) {
      fail('wildfly_dir is required')
    }

    if (!$host_config) {
      fail('host_config is required')
    }

    if $facts['wildfly_is_running'] {
      debug("Will connect to domain controller to remove server-config ${server_name}")

      wildfly_cli { "/host=${hostname}/server-config=${server_name}:stop(blocking=true)":
        skip_absent => true,
        onlyif      => "(result != STOPPED) of /host=${hostname}/server-config=${server_name}:read-attribute(name=status)",
        username    => $username,
        password    => $password,
        host        => $controller_address,
        port        => $controller_mgmt_port,
      }
      -> wildfly_resource { "/host=${hostname}/server-config=${server_name}":
        ensure   => absent,
        username => $username,
        password => $password,
        host     => $controller_address,
        port     => $controller_mgmt_port,
      }
    } else {
      debug("Using augeas to remove server-config ${server_name}")

      augeas { "manage-host-controller-server-${server_name}":
        lens    => 'Xml.lns',
        incl    => "${wildfly_dir}/domain/configuration/${host_config}",
        changes => "rm host/servers/server[#attribute/name='${server_name}']",
        onlyif  => "match host/servers/server[#attribute/name='${server_name}'] size != 0",
      }
    }
  }
}
