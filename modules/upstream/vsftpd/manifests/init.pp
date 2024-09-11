# @summary A more Puppety way of installing and managing the vsftpd daemon.
#
# @example
#   class { 'vsftpd':
#     pam_service_name => 'ftp',
#     pasv_enable      => true,
#     pasv_min_port    => 1024,
#     pasv_max_port    => 1048,
#     pasv_address     => '127.0.0.1',
#   }
#
# @author Aneesh C <aneeshchandrasekharan@gmail.com>, Philipp Seiler <p.seiler@linuxmail.org>
#
# @param config_path
#   The path to the main configuration file of vsftpd. Defaults to the os specific
#   path.
#
# @param package_name
#   The name of the package.
#
#   Default value: `vsftpd`
#
# @param service_name
#   The name of systemd service
#
#   Default value: `vsftpd`
#
# @param manage_service
#   Wether to manage the systemd service or not.
#
# @param service_enable
#   Wether to enable the service when booting or not.
#
# @param service_ensure
#   Control if the service is running or not
#
# @param template
#   Path to the template the file resource is using.
#
# @param allow_anon_ssl
#   Only applies if ssl_enable is active. If set to YES, anonymous users will be allowed to use secured SSL connections.
#
#   Default when Boolean is undef: NO
#
# @param allow_root_squashed_chroot
#
# @param allow_writeable_chroot
#
# @param anon_mkdir_write_enable
#   If set to YES, anonymous users will be permitted to create new directories under certain conditions.
#   For this to work, the option write_enable must be activated, and the anonymous ftp user must have write
#   permission on the parent directory.
#
#   Default when Boolean is undef: NO
#
# @param anon_other_write_enable
#   If set to YES, anonymous users will be permitted to perform write operations other than upload and create
#   directory, such as deletion and renaming. This is generally not recommended but included for completeness.
#
#   Default when Boolean is undef: NO
#
# @param anon_upload_enable
#   If set to YES, anonymous users will be permitted to upload files under certain conditions. For this to work,
#   the option write_enable must be activated, and the anonymous ftp user must have write permission on desired
#   upload locations. This setting is also required for virtual users to upload; by default, virtual users are
#    treated with anonymous (i.e. maximally restricted) privilege.
#
#   Default when Boolean is undef: NO
#
# @param anon_world_readable_only
#   When enabled, anonymous users will only be allowed to download files which are world readable. This is recognising
#    that the ftp user may own files, especially in the presence of uploads.
#
#   Default when Boolean is undef: YES
#
# @param anonymous_enable
#   Controls whether anonymous logins are permitted or not. If enabled, both the usernames ftp and anonymous are
#    recognised as anonymous logins.
#
#   Default: YES
#
# @param ascii_download_enable
#   When enabled, ASCII mode data transfers will be honoured on downloads.
#
#   Default: NO
#
# @param ascii_upload_enable
#   When enabled, ASCII mode data transfers will be honoured on uploads.
#
#   Default: NO
#
# @param async_abor_enable
#    When enabled, a special FTP command known as "async ABOR" will be enabled. Only ill advised FTP clients will use this
#   feature. Additionally, this feature is awkward to handle, so it is disabled by default. Unfortunately, some FTP clients
#   will hang when cancelling a transfer unless this feature is available, so you may wish to enable it.
#
# Default: NO
#
# @param background
#   When enabled, and vsftpd is started in "listen" mode, vsftpd will background the listener process. i.e. control will
#   immediately be returned to the shell which launched vsftpd.
#
#   Default: YES
#
# @param check_shell
#   Note! This option only has an effect for non-PAM builds of vsftpd. If disabled, vsftpd will not check /etc/shells for
#   a valid user shell for local logins.
#
#   Default: YES
#
# @param chmod_enable
#   When enabled, allows use of the SITE CHMOD command. NOTE! This only applies to local users. Anonymous users never get
#   to use SITE CHMOD.
#
# Default: YES
#
# @param chown_uploads
#   If enabled, all anonymously uploaded files will have the ownership changed to the user specified in the setting
#   chown_username. This is useful from an administrative, and perhaps security, standpoint.
#
#   Default: NO
#
# @param chroot_list_enable
#   If activated, you may provide a list of local users who are placed in a chroot() jail in their home directory upon
#   login. The meaning is slightly different if chroot_local_user is set to YES. In this case, the list becomes a list
#   of users which are NOT to be placed in a chroot() jail. By default, the file containing this list is
#   /etc/vsftpd/chroot_list, but you may override this with the chroot_list_file setting.
#
#   Default: NO
#
# @param chroot_local_user
#   If set to YES, local users will be (by default) placed in a chroot() jail in their home directory after login. Warning:
#   This option has security implications, especially if the users have upload permission, or shell access. Only enable if
#   you know what you are doing. Note that these security implications are not vsftpd specific. They apply to all FTP daemons
#   which offer to put local users in chroot() jails.
#
#   Default: NO
#
# @param connect_from_port_20
#   This controls whether PORT style data connections use port 20 (ftp-data) on the server machine. For security reasons, some
#   clients may insist that this is the case. Conversely, disabling this option enables vsftpd to run with slightly less privilege.
#
#   Default: NO (but the sample config file enables it)
#
# @param debug_ssl
#
# @param delete_failed_uploads
#
# @param deny_email_enable
#
# @param dirlist_enable
#
# @param dirmessage_enable
#
# @param download_enable
#
# @param dual_log_enable
#
# @param force_dot_files
#
# @param force_anon_data_ssl
#
# @param force_anon_logins_ssl
#
# @param force_local_data_ssl
#
# @param force_local_logins_ssl
#
# @param guest_enable
#
# @param hide_ids
#
# @param implicit_ssl
#
# @param listen
#
# @param listen_ipv6
#
# @param local_enable
#
# @param lock_upload_files
#
# @param log_ftp_protocol
#
# @param ls_recurse_enable
#
# @param mdtm_write
#
# @param no_anon_password
#
# @param no_log_lock
#
# @param one_process_model
#
# @param passwd_chroot_enable
#
# @param pasv_addr_resolve
#
# @param pasv_enable
#
# @param pasv_promiscuous
#
# @param port_enable
#
# @param port_promiscuous
#
# @param require_cert
#
# @param require_ssl_reuse
#
# @param run_as_launching_user
#
# @param secure_email_list_enable
#
# @param session_support
#
# @param setproctitle_enable
#
# @param ssl_enable
#
# @param ssl_request_cert
#
# @param ssl_sslv2
#
# @param ssl_sslv3
#
# @param ssl_tlsv1
#
# @param strict_ssl_read_eof
#
# @param strict_ssl_write_shutdown
#
# @param syslog_enable
#
# @param tcp_wrappers
#
# @param text_userdb_names
#
# @param tilde_user_enable
#
# @param use_localtime
#
# @param use_sendfile
#
# @param userlist_deny
#
# @param userlist_enable
#
# @param validate_cert
#
# @param virtual_use_local_privs
#
# @param write_enable
#
# @param xferlog_enable
#
# @param xferlog_std_format
#
# @param accept_timeout
#
# @param address_space_limit
#
# @param anon_max_rate
#
# @param anon_umask
#
# @param chown_upload_mode
#
# @param connect_timeout
#
# @param data_connection_timeout
#
# @param delay_failed_login
#
# @param delay_successful_login
#
# @param file_open_mode
#
# @param ftp_data_port
#
# @param idle_session_timeout
#
# @param listen_port
#
# @param local_max_rate
#
# @param local_umask
#
# @param max_clients
#
# @param max_login_fails
#
# @param max_per_ip
#
# @param pasv_min_port
#
# @param pasv_max_port
#
# @param trans_chunk_size
#
# @param anon_root
#
# @param banned_email_file
#
# @param banner_file
#
# @param ca_certs_file
#
# @param chown_username
#
# @param chroot_list_file
#
# @param cmds_allowed
#
# @param cmds_denied
#
# @param deny_file
#
# @param dsa_cert_file
#
# @param dsa_private_key_file
#
# @param email_password_file
#
# @param ftp_username
#
# @param ftpd_banner
#
# @param guest_username
#
# @param hide_file
#
# @param listen_address
#
# @param listen_address6
#
# @param local_root
#
# @param message_file
#
# @param nopriv_user
#
# @param pam_service_name
#
# @param pasv_address
#
# @param rsa_cert_file
#
# @param rsa_private_key_file
#
# @param secure_chroot_dir
#
# @param ssl_ciphers
#
# @param user_config_dir
#
# @param user_sub_token
#
# @param userlist_file
#
# @param vsftpd_log_file
#
# @param xferlog_file
#
class vsftpd (
  String $config_path,
  String $package_name,
  String $service_name,
  Boolean $manage_service                                      = true,
  String $template                                             = 'vsftpd/configfile.erb',
  Variant[Boolean, Enum['manual', 'mask']] $service_enable     = true,
  Variant[Boolean, Enum['running', 'stopped']] $service_ensure = 'running',

  Optional[Boolean] $allow_anon_ssl             = undef,
  Optional[Boolean] $allow_root_squashed_chroot = undef,
  Optional[Boolean] $allow_writeable_chroot     = undef,
  Optional[Boolean] $anon_mkdir_write_enable    = undef,
  Optional[Boolean] $anon_other_write_enable    = undef,
  Optional[Boolean] $anon_upload_enable         = undef,
  Optional[Boolean] $anon_world_readable_only   = undef,
  Optional[Boolean] $anonymous_enable           = undef,
  Optional[Boolean] $ascii_download_enable      = undef,
  Optional[Boolean] $ascii_upload_enable        = undef,
  Optional[Boolean] $async_abor_enable          = undef,
  Optional[Boolean] $background                 = undef,
  Optional[Boolean] $check_shell                = undef,
  Optional[Boolean] $chmod_enable               = undef,
  Optional[Boolean] $chown_uploads              = undef,
  Optional[Boolean] $chroot_list_enable         = undef,
  Optional[Boolean] $chroot_local_user          = undef,
  Optional[Boolean] $connect_from_port_20       = undef,
  Optional[Boolean] $debug_ssl                  = undef,
  Optional[Boolean] $delete_failed_uploads      = undef,
  Optional[Boolean] $deny_email_enable          = undef,
  Optional[Boolean] $dirlist_enable             = undef,
  Optional[Boolean] $dirmessage_enable          = undef,
  Optional[Boolean] $download_enable            = undef,
  Optional[Boolean] $dual_log_enable            = undef,
  Optional[Boolean] $force_dot_files            = undef,
  Optional[Boolean] $force_anon_data_ssl        = undef,
  Optional[Boolean] $force_anon_logins_ssl      = undef,
  Optional[Boolean] $force_local_data_ssl       = undef,
  Optional[Boolean] $force_local_logins_ssl     = undef,
  Optional[Boolean] $guest_enable               = undef,
  Optional[Boolean] $hide_ids                   = undef,
  Optional[Boolean] $implicit_ssl               = undef,
  Optional[Boolean] $listen                     = undef,
  Optional[Boolean] $listen_ipv6                = undef,
  Optional[Boolean] $local_enable               = undef,
  Optional[Boolean] $lock_upload_files          = undef,
  Optional[Boolean] $log_ftp_protocol           = undef,
  Optional[Boolean] $ls_recurse_enable          = undef,
  Optional[Boolean] $mdtm_write                 = undef,
  Optional[Boolean] $no_anon_password           = undef,
  Optional[Boolean] $no_log_lock                = undef,
  Optional[Boolean] $one_process_model          = undef,
  Optional[Boolean] $passwd_chroot_enable       = undef,
  Optional[Boolean] $pasv_addr_resolve          = undef,
  Optional[Boolean] $pasv_enable                = undef,
  Optional[Boolean] $pasv_promiscuous           = undef,
  Optional[Boolean] $port_enable                = undef,
  Optional[Boolean] $port_promiscuous           = undef,
  Optional[Boolean] $require_cert               = undef,
  Optional[Boolean] $require_ssl_reuse          = undef,
  Optional[Boolean] $run_as_launching_user      = undef,
  Optional[Boolean] $secure_email_list_enable   = undef,
  Optional[Boolean] $session_support            = undef,
  Optional[Boolean] $setproctitle_enable        = undef,
  Optional[Boolean] $ssl_enable                 = undef,
  Optional[Boolean] $ssl_request_cert           = undef,
  Optional[Boolean] $ssl_sslv2                  = undef,
  Optional[Boolean] $ssl_sslv3                  = undef,
  Optional[Boolean] $ssl_tlsv1                  = undef,
  Optional[Boolean] $strict_ssl_read_eof        = undef,
  Optional[Boolean] $strict_ssl_write_shutdown  = undef,
  Optional[Boolean] $syslog_enable              = undef,
  Optional[Boolean] $tcp_wrappers               = undef,
  Optional[Boolean] $text_userdb_names          = undef,
  Optional[Boolean] $tilde_user_enable          = undef,
  Optional[Boolean] $use_localtime              = undef,
  Optional[Boolean] $use_sendfile               = undef,
  Optional[Boolean] $userlist_deny              = undef,
  Optional[Boolean] $userlist_enable            = undef,
  Optional[Boolean] $validate_cert              = undef,
  Optional[Boolean] $virtual_use_local_privs    = undef,
  Optional[Boolean] $write_enable               = undef,
  Optional[Boolean] $xferlog_enable             = undef,
  Optional[Boolean] $xferlog_std_format         = undef,

  Optional[Integer] $accept_timeout             = undef,
  Optional[Integer] $address_space_limit        = undef,
  Optional[Integer] $anon_max_rate              = undef,
  Optional[String] $anon_umask                  = undef,
  Optional[String] $chown_upload_mode           = undef,
  Optional[Integer] $connect_timeout            = undef,
  Optional[Integer] $data_connection_timeout    = undef,
  Optional[Integer] $delay_failed_login         = undef,
  Optional[Integer] $delay_successful_login     = undef,
  Optional[String] $file_open_mode              = undef,
  Optional[Integer] $ftp_data_port              = undef,
  Optional[Integer] $idle_session_timeout       = undef,
  Optional[Integer] $listen_port                = undef,
  Optional[Integer] $local_max_rate             = undef,
  Optional[String] $local_umask                 = undef,
  Optional[Integer] $max_clients                = undef,
  Optional[Integer] $max_login_fails            = undef,
  Optional[Integer] $max_per_ip                 = undef,
  Optional[Integer] $pasv_min_port              = undef,
  Optional[Integer] $pasv_max_port              = undef,
  Optional[Integer] $trans_chunk_size           = undef,

  Optional[String] $anon_root                   = undef,
  Optional[String] $banned_email_file           = undef,
  Optional[String] $banner_file                 = undef,
  Optional[String] $ca_certs_file               = undef,
  Optional[String] $chown_username              = undef,
  Optional[String] $chroot_list_file            = undef,
  Optional[Array[Vsftpd::Cmd]] $cmds_allowed    = undef,
  Optional[Array[Vsftpd::Cmd]] $cmds_denied     = undef,
  Optional[Array[String]] $deny_file            = undef,
  Optional[String] $dsa_cert_file               = undef,
  Optional[String] $dsa_private_key_file        = undef,
  Optional[String] $email_password_file         = undef,
  Optional[String] $ftp_username                = undef,
  Optional[String] $ftpd_banner                 = undef,
  Optional[String] $guest_username              = undef,
  Optional[Array[String]] $hide_file            = undef,
  Optional[String] $listen_address              = undef,
  Optional[String] $listen_address6             = undef,
  Optional[String] $local_root                  = undef,
  Optional[String] $message_file                = undef,
  Optional[String] $nopriv_user                 = undef,
  Optional[String] $pam_service_name            = undef,
  Optional[String] $pasv_address                = undef,
  Optional[String] $rsa_cert_file               = undef,
  Optional[String] $rsa_private_key_file        = undef,
  Optional[String] $secure_chroot_dir           = undef,
  Optional[String] $ssl_ciphers                 = undef,
  Optional[String] $user_config_dir             = undef,
  Optional[String] $user_sub_token              = undef,
  Optional[String] $userlist_file               = undef,
  Optional[String] $vsftpd_log_file             = undef,
  Optional[String] $xferlog_file                = undef,
) {
  case $facts['os']['family'] {
    'Debian','RedHat','Suse': {}
    default: {
      fail("${facts['os']['name']} not supported.")
    }
  }

  package { $package_name:
    ensure => installed,
  }

  # check for parameters used without another parameter
  if ($chown_username != undef) and ($chown_uploads == false or $chown_uploads == undef) {
    fail('Cannot use "chown_username" without "chown_uploads" set to true')
  }
  if ($message_file != undef) and ($dirmessage_enable == false or $dirmessage_enable == undef) {
    fail('Cannot use "message_file" without "dirmessage_enable" set to true')
  }

  # check these umask parameter for validity
  if $anon_umask != undef and ($anon_umask !~ /^[0-7]?[0-7][0-7][0-7]$/) {
    fail('umask must be an octal value. F.e. 0022')
  }
  if $local_umask != undef and ($local_umask !~ /^[0-7]?[0-7][0-7][0-7]$/) {
    fail('umask must be an octal value. F.e. 0022')
  }
  if $file_open_mode != undef and ($file_open_mode !~ /^[0-7][0-7][0-7][0-7]$/) {
    fail('file open mode must be an octal value. F.e. 0660')
  }
  if $chown_upload_mode != undef and ($chown_upload_mode !~ /^[0-7][0-7][0-7][0-7]$/) {
    fail('chown upload mode must be an octal value. F.e. 0660')
  }

  file { $config_path:
    ensure  => file,
    content => template($template),
    require => Package[$package_name],
  }
  if $manage_service {
    service { $service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package[$package_name],
      subscribe => File[$config_path],
    }
  }
}
