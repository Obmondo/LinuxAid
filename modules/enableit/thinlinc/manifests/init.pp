# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc
class thinlinc (
  Stdlib::Absolutepath $install_dir = '/opt/thinlinc',
  String $version = '4.9.0',

  # general settings
  Boolean                $log_to_file       = true,
  Stdlib::Absolutepath   $log_dir           = '/var/log/thinlinc',
  Boolean                $log_to_syslog     = false,
  String                 $syslog_facility   = 'local0',
  Stdlib::Absolutepath   $syslog_socket     = '/dev/log',
  Optional[Stdlib::Host] $syslog_host       = undef,
  ThinLinc::LogLevel     $default_log_level = 'INFO',

  # tlwebadm
  String                     $tlwebadm_username        = 'admin',
  String                     $tlwebadm_password        = undef,
  Stdlib::Absolutepath       $tlwebadm_cert            = '/opt/thinlinc/etc/tlwebadm/server.crt',
  Stdlib::Absolutepath       $tlwebadm_cert_key        = '/opt/thinlinc/etc/tlwebadm/server.key',
  Stdlib::Port               $tlwebadm_listen_port     = 1010,
  String                     $tlwebadm_gnutls_priority = 'NORMAL:-VERS-SSL3.0',
  Array[Stdlib::IP::Address] $tlwebadm_allowed_hosts   = [],

  # profile
  String        $profile_default    = 'xfce',
  Array[String] $profile_order      = [
    'gnome',
    'kde',
    'xfce',
    'cinnamon',
    'mate',
    'lxde',
  ],
  Boolean       $profile_install    = true,
  Boolean       $profile_show_intro = false,

  # session start
  ThinLinc::HexRGB         $session_background_color = '#374691',
  Stdlib::Absolutepath     $session_background_image = '/opt/thinlinc/share/xstartup/background.png',
  ThinLinc::KeyboardLayout $session_keyboard_layout  = 'us(alt-intl)',

  # vsmserver
  String                         $vsmserver_admin_email              = 'root@localhost',
  Array[Stdlib::Host]            $vsmserver_terminal_servers         =  ['127.0.0.1',],
  Integer[0,default]             $vsmserver_ram_per_user_mb          = 100,
  Integer[0,default]             $vsmserver_bogomips_per_user        = 600,
  Integer[0,default]             $vsmserver_existing_users_weight    = 4,
  Integer[0,default]             $vsmserver_load_update_cycle        = 40,
  Integer[0,default]             $vsmserver_max_session_per_user     = 1,
  Optional[Array[Stdlib::Host]]  $vsmserver_allowed_clients          = undef,
  Optional[Array[Stdlib::Host]]  $vsmserver_subcluster_agents        = undef,
  Optional[Array[String]]        $vsmserver_allowed_groups           = undef,
  Boolean                        $vsmserver_unbind_ports_at_login    = true,
  Optional[Array[String]]        $vsmserver_explicit_agent_selection = undef,
  Stdlib::Port                   $vsmserver_listen_port              = 9000,

  Boolean                        $vsmserver_enable_ha                = false,
  Boolean                        $vsmagent_enable_ha                = false,
  Optional[Array[Stdlib::Host]]  $vsmserver_ha_nodes                 = undef,

  Boolean                        $vsmserver_log_to_file              = $log_to_file,
  Optional[Stdlib::Absolutepath] $vsmserver_log_dir                  = $log_dir,
  Boolean                        $vsmserver_log_to_syslog            = $log_to_syslog,
  Optional[String]               $vsmserver_syslog_facility          = $syslog_facility,
  Optional[Stdlib::Absolutepath] $vsmserver_syslog_socket            = $syslog_socket,
  Optional[Stdlib::Host]         $vsmserver_syslog_host              = $syslog_host,
  ThinLinc::LogLevel             $vsmserver_default_log_level        = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_extcmd_log_level         = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_session_log_level        = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_shadow_log_level         = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_loadinfo_log_level       = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_license_log_level        = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_xmlrpc_log_level         = $default_log_level,
  ThinLinc::LogLevel             $vsmserver_ha_log_level             = $default_log_level,
  Optional[Stdlib::IP::Address]  $vsmserver_loadbalancer_ip          = undef,
  # shadow mode
  ThinLinc::ShadowMode $shadowing_shadow_mode = 'ask',
  Optional[Array[String]] $shadowing_allowed_shadowers = undef,

  # vsm
  Stdlib::Port                  $vsm_server_port = 9000,
  Stdlib::Port                  $vsm_agent_port = 904,
  Stdlib::Port                  $vsm_vnc_port_base = 5900,
  Stdlib::Port                  $vsm_tunnel_bind_base = 4900,
  Integer                       $vsm_tunnel_slots_per_session = 10,
  Array[Tuple[String, Integer]] $vsm_tunnel_services = [
    [ 'esound', 0 ],
    [ 'serial', 1 ],
    [ 'serial2', 2 ],
    [ 'lpd', 3 ],
    [ 'nfs', 4 ],
    [ 'pulseaudio', 5],
    [ 'smartcard', 6],
  ],

  # vsmagent
  Stdlib::Host                   $vsmagent_master_hostname     = 'localhost',
  Optional[Array[Stdlib::Host]]  $vsmagent_allowed_clients     = undef,
  Boolean                        $vsmagent_make_homedir        = true,
  Stdlib::FileMode               $vsmagent_make_homedir_mode   = '0700',
  String                         $vsmagent_default_geometry    = '1024 768',
  Boolean                        $vsmagent_single_signon       = true,
  Array[String]                  $vsmagent_xserver_args        = [
    '-br',
    '-localhost',
    '-verbose 3',
  ],
  ThinLinc::XAuthorityLocation   $vsmagent_xauthority_location = 'sessiondir',
  Optional[Stdlib::Host]         $vsmagent_agent_hostname      = undef,
  Stdlib::Port                   $vsmagent_max_session_port    = 32767,
  Stdlib::Port                   $vsmagent_lowest_user_port    = 32768,
  Integer[0,default]             $vsmagent_xvnc_start_timeout  = 250,
  Stdlib::Port                   $vsmagent_listen_port         = 904,
  Hash[String, String]           $vsmagent_default_environment = {
    'PATH'            => '/bin:/usr/bin:/opt/thinlinc/bin:/usr/local/bin:/usr/bin/X11:/sbin:/usr/sbin:/usr/local/sbin',
    'LD_LIBRARY_PATH' => '/opt/thinlinc/lib64:/opt/thinlinc/lib',
  },
  Integer[1,default]             $vsmagent_display_min         = 10,
  Integer[1,default]             $vsmagent_display_max         = 2000,
  Array[Stdlib::IP::Address]     $vsmagent_allowed_hosts       = [],

  Boolean                        $vsmagent_log_to_file       = $log_to_file,
  Optional[Stdlib::Absolutepath] $vsmagent_log_dir           = $log_dir,
  Boolean                        $vsmagent_log_to_syslog     = $log_to_syslog,
  Optional[String]               $vsmagent_syslog_facility   = $syslog_facility,
  Optional[Stdlib::Absolutepath] $vsmagent_syslog_socket     = $syslog_socket,
  Optional[Stdlib::Host]         $vsmagent_syslog_host       = $syslog_host,
  ThinLinc::LogLevel             $vsmagent_default_log_level = $default_log_level,
  ThinLinc::LogLevel             $vsmagent_extcmd_log_level  = $default_log_level,
  ThinLinc::LogLevel             $vsmagent_session_log_level = $default_log_level,
  ThinLinc::LogLevel             $vsmagent_xmlrpc_log_level  = $default_log_level,

  # webaccess
  Stdlib::Absolutepath $webaccess_cert            = '/opt/thinlinc/etc/tlwebaccess/server.crt',
  Stdlib::Absolutepath $webaccess_cert_key        = '/opt/thinlinc/etc/tlwebaccess/server.key',
  Stdlib::Absolutepath $webaccess_login_page      = '/',
  Stdlib::Port         $webaccess_listen_port     = 300,
  String               $webaccess_gnutls_priority = 'NORMAL:-VERS-SSL3.0',

  Boolean                $webaccess_log_to_file       = $log_to_file,
  Stdlib::Absolutepath   $webaccess_log_dir           = $log_dir,
  Boolean                $webaccess_log_to_syslog     = $log_to_syslog,
  String                 $webaccess_syslog_facility   = $syslog_facility,
  Stdlib::Absolutepath   $webaccess_syslog_socket     = $syslog_socket,
  Optional[Stdlib::Host] $webaccess_syslog_host       = $syslog_host,
  ThinLinc::LogLevel     $webaccess_default_log_level = $default_log_level,
  Boolean                $only_agents                 = false,

) {

  Logrotate::Rule {
    ensure        => 'present',
    rotate_every  => 'daily',
    rotate        => 30,
    missingok     => true,
    ifempty       => false,
    compress      => true,
    delaycompress => false,
    dateext       => true,
  }

  include ::thinlinc::install
  include ::thinlinc::service
  include ::thinlinc::profiles
  include ::thinlinc::session
  include ::thinlinc::tlwebadm
  include ::thinlinc::vsm
  include ::thinlinc::vsmagent
  include ::thinlinc::webaccess

  if !$only_agents {
    include ::thinlinc::vsmserver
    include ::thinlinc::shadowing
  }
}
