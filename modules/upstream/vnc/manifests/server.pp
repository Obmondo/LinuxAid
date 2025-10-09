# @summary Install and configure the tigervnc server
#
# This class will install and configure the tigervnc
# server, setup defaults, and manage the services.
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc server packages
# @param manage_config
#   Should this class manage the config
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
# @param polkit_file
#   Your /etc/polkit-1/rules.d/25-puppet-vncserver.rules
# @param polkit_file_mode
#   Your /etc/polkit-1/rules.d/25-puppet-vncserver.rules permissions
#   It should pretty much always be 644
# @param manage_services
#   Should this class manage the vncserver services
# @param user_can_manage
#   Should users be able to manage the systemd service by default
# @param extra_users_can_manage
#   Who else should be able to manage the VNC sessions
# @param vnc_home_conf
#   Where does VNC keep its config (/.vnc)
#   NOTE: MUST start with `/`
#   NOTE: MUST NOT end with `/`
# @param seed_home_vnc
#   Should this class generate a per-user ~/.vnc if it doesn't exist?
# @param systemd_template_startswith
#   What does the vnc template service start with, including the '@'
# @param systemd_template_endswith
#   What does the vnc template service end with (not including the '.')
# @param vnc_servers
#   A hash of VNC servers to setup  Format:
#   userA:
#     comment: Sometimes you've gotta write it down
#     displaynumber: 1
#     ensure: running
#     enable: true
#     user_can_manage: true
#     seed_home_vnc: false
#   userB:
#     displaynumber: 2
#     ensure: stopped
#     enable: false
#     user_can_manage: false
#
#  The default state is running/enabled, not user managed
#
class vnc::server (
  Boolean $manage_packages,
  Array $packages,
  String $packages_ensure,
  Boolean $manage_config,
  Stdlib::Absolutepath $config_defaults_file,
  Hash[String, Variant[String, Undef]] $config_defaults,
  Stdlib::Absolutepath $config_mandatory_file,
  Hash[String, Variant[String, Undef]] $config_mandatory,
  Stdlib::Absolutepath $vncserver_users_file,
  Stdlib::Absolutepath $polkit_file,
  Stdlib::Absolutepath $vnc_home_conf,
  String $polkit_file_mode,
  Boolean $manage_services,
  Boolean $user_can_manage,
  Boolean $seed_home_vnc,
  Array[String] $extra_users_can_manage,
  String $systemd_template_startswith,
  String $systemd_template_endswith,

  # lint:ignore:140chars
  Hash[String, Hash[Enum['displaynumber', 'user_can_manage', 'seed_home_vnc', 'comment', 'ensure', 'enable', 'extra_users_can_manage'], Variant[Array[String], String, Integer, Boolean, Undef]]] $vnc_servers,
  # lint:endignore
) {
  contain 'vnc::server::install'
  contain 'vnc::server::config'
  contain 'vnc::server::service'

  Class['vnc::server::install'] -> Class['vnc::server::config'] ~> Class['vnc::server::service']
  Class['vnc::server::install'] ~> Class['vnc::server::service']
}
