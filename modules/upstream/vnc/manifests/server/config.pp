# @api private
#
# @summary Configure the VNC services
#
# @param manage_config
#   Should this class manage the config
# @param seed_home_vnc
#   Should this class generate a per-user ~/.vnc if it doesn't exist?
# @param config_defaults_file
#   Your /etc/tigervnc/vncserver-config-defaults
# @param config_defaults
#   Settings to put in /etc/tigervnc/vncserver-config-defaults
# @param config_mandatory_file
#   Your /etc/tigervnc/vncserver-config-mandatory
# @param config_mandatory
#   Settings to put in /etc/tigervnc/vncserver-config-mandatory
# @param vncserver_users_file
#   Your /etc/tigervnc/vncserver.users
# @param vnc_servers
#   VNC server sessions to configure and stub out
#   See the server.pp documentation for structure
# @param user_can_manage
#   Should users be able to manage the systemd service by default
# @param polkit_file
#   Your /etc/polkit-1/rules.d/25-puppet-vncserver.rules
# @param polkit_file_mode
#   Your /etc/polkit-1/rules.d/25-puppet-vncserver.rules permissions
#   It should pretty much always be 644
# @param systemd_template_startswith
#   What does the vnc template service start with, not including the '@'
# @param systemd_template_endswith
#   What does the vnc template service end with, not including the '.'
class vnc::server::config (
  # lint:ignore:parameter_types
  $manage_config         = $vnc::server::manage_config,
  $seed_home_vnc         = $vnc::server::seed_home_vnc,
  $config_defaults_file  = $vnc::server::config_defaults_file,
  $config_defaults       = $vnc::server::config_defaults,
  $config_mandatory_file = $vnc::server::config_mandatory_file,
  $config_mandatory      = $vnc::server::config_mandatory,
  $vncserver_users_file  = $vnc::server::vncserver_users_file,
  $user_can_manage       = $vnc::server::user_can_manage,
  $polkit_file           = $vnc::server::polkit_file,
  $polkit_file_mode      = $vnc::server::polkit_file_mode,

  $systemd_template_startswith = $vnc::server::systemd_template_startswith,
  $systemd_template_endswith   = $vnc::server::systemd_template_endswith,

  $vnc_servers = $vnc::server::vnc_servers
  # lint:endignore
) inherits vnc::server {
  assert_private()

  if $manage_config {
    file { unique([dirname($config_defaults_file), dirname($config_mandatory_file)]):
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { $config_defaults_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/config.epp', { 'settings' => $config_defaults }),
      notify  => Class['Vnc::Server::Service'],
    }

    file { $config_mandatory_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/config.epp', { 'settings' => $config_mandatory }),
      notify  => Class['Vnc::Server::Service'],
    }

    file { $vncserver_users_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/vncserver.users.epp', { 'vnc_servers' => $vnc_servers, 'user_can_manage' => $user_can_manage }),
    }

    concat { $polkit_file:
      owner => 'root',
      group => 'root',
      mode  => $polkit_file_mode,
    }

    concat::fragment { 'polkit_header':
      target  => $polkit_file,
      content => "/* THIS FILE IS MANAGED BY PUPPET */\n",
      order   => '01',
    }

    $vnc_servers.keys.sort.each |$username| {
      unless 'displaynumber' in $vnc_servers[$username] {
        fail("You must set the 'displaynumber' property for ${username}'s vnc server")
      }

      if 'user_can_manage' in $vnc_servers[$username] {
        $user_mange_systemd_service = $vnc_servers[$username]['user_can_manage']
      } else {
        $user_mange_systemd_service = $user_can_manage
      }

      if $user_mange_systemd_service {
        $polkit_hash = {
          'systemd_template_startswith' => $systemd_template_startswith,
          'systemd_template_endswith'   => $systemd_template_endswith,
          'username'                    => $username,
          'displaynumber'               => $vnc_servers[$username]['displaynumber'],
        }

        concat::fragment { "polkit entry for ${username} vnc service":
          target  => $polkit_file,
          order   => 20,
          content => epp('vnc/etc/polkit-1/rules.d/25-puppet-vncserver.rules.epp', $polkit_hash),
        }
      }

      if 'seed_home_vnc' in $vnc_servers[$username] {
        $seed_user_home_vnc = $vnc_servers[$username]['seed_home_vnc']
      } else {
        $seed_user_home_vnc = $seed_home_vnc
      }

      if $seed_user_home_vnc {
        exec { "create ~${username}/.vnc":
          command  => "mkdir -p $(getent passwd ${username} | cut -d: -f6)/.vnc",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc",
          onlyif   => "getent passwd ${username}",
        }
        exec { "chmod 700 ~${username}/.vnc":
          command  => "chmod 700 $(getent passwd ${username} | cut -d: -f6)/.vnc",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc --printf=%a|grep 700",
          onlyif   => "getent passwd ${username}",
        }

        exec { "create ~${username}/.vnc/config":
          command  => "echo '# see also ${config_defaults}' > $(getent passwd ${username} | cut -d: -f6)/.vnc/config",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc/config",
          onlyif   => "getent passwd ${username}",
        }
        exec { "chmod 600 ~${username}/.vnc/config":
          command  => "chmod 600 $(getent passwd ${username} | cut -d: -f6)/.vnc/config",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc/config --printf=%a|grep 600",
          onlyif   => "getent passwd ${username}",
        }

        exec { "create ~${username}/.vnc/passwd":
          command  => "head -1 /dev/urandom > $(getent passwd ${username} | cut -d: -f6)/.vnc/passwd",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc/passwd",
          onlyif   => "getent passwd ${username}",
        }
        exec { "chmod 600 ~${username}/.vnc/passwd":
          command  => "chmod 600 $(getent passwd ${username} | cut -d: -f6)/.vnc/passwd",
          path     => ['/usr/bin', '/usr/sbin',],
          provider => 'shell',
          user     => $username,
          group    => 'users',
          unless   => "stat $(getent passwd ${username} | cut -d: -f6)/.vnc/passwd --printf=%a|grep 600",
          onlyif   => "getent passwd ${username}",
        }
      }
    }
  }
}
