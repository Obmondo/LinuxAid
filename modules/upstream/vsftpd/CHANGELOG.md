# Changelog
## 8.0.1
* drop support for outdated Debian 7 and add Debian 10 instead

## 8.0.0
* reworked module to use puppet booleans instead of 'YES'/'NO'
* a lot rspec tests added
* * tests if every parameter is written correctly into the configuration
* * tests for umasks
* * tests for parameters which depend on another
* * basic tests for all supported operating systems
* * test if the catalog compiling fails for an unsupported operating system
* umasks in the configuration file now being checked for validity
* allowed/denied ftp commands are now being checked for valid FTP commands and are now an array
* ``deny_file``/``hide_file`` is now an array
* configuration file cleanup and generalizing
* more additional parameters can be used and overriden:
* * control if the service should be running and enabled ``manage_service``
* * the package name ``package_name``
* * the config file path ``config_path``
* * the service name ``service_name``
* * the erb template used to render the configuration file ``template``
* added support for Suse based operating systems
* Added support for the following/all remaining configuration parameters

### Boolean parameters
* ``async_abor_enable``
* ``allow_root_squashed_chroot``
* ``background``
* ``check_shell``
* ``chmod_enable``
* ``debug_ssl``
* ``deny_email_enable``
* ``dirlist_enable``
* ``force_dot_files``
* ``force_anon_data_ssl``
* ``force_anon_logins_ssl``
* ``implicit_ssl``
* ``lock_upload_files``
* ``log_ftp_protocol``
* ``ls_recurse_enable``
* ``mdtm_write``
* ``no_anon_password``
* ``no_log_lock``
* ``one_process_model``
* ``passwd_chroot_enable``
* ``pasv_addr_resolve``
* ``pasv_promiscuous``
* ``port_enable``
* ``port_promiscuous``
* ``require_cert``
* ``run_as_launching_user``
* ``secure_email_list_enable``
* ``session_support``
* ``setproctitle_enable``
* ``ssl_request_cert``
* ``strict_ssl_read_eof``
* ``strict_ssl_write_shutdown``
* ``text_userdb_names``
* ``tilde_user_enable``
* ``use_sendfile``
* ``validate_cert``
* ``virtual_use_local_privs``

### Numeric/Integer parameters
* ``anon_max_rate``
* ``accept_timeout``
* ``address_space_limit``
* ``chown_upload_mode``
* ``data_connect_timeout``
* ``delay_failed_login``
* ``delay_successful_login``
* ``max_login_fails``
* ``trans_chunk_size``
* ``idle_session_timeout``
* ``data_connection_timeout``

### String parameters
* ``banned_email_file``
* ``ca_certs_file``
* ``dsa_cert_file``
* ``dsa_private_key_file``
* ``email_password_file``
* ``listen_address``
* ``listen_address6``
* ``local_root``
* ``message_file``
* ``user_sub_token``
* ``vsftpd_log_file``
* ``nopriv_user``
* ``xferlog_file``

## 7.0.3
* fixed breaking syntax mistake anon\_root in config template (thanks pingram3030)

## 7.0.2
* made module compatible with PDK

## 7.0.1
* configuration changes now restarts the vsftpd daemon if it's a RedHat based system
* changed project name, urls, etc. (upstream doesn't care about contributions)

## 7.0.0
* moved comments for configuration parameter into the if block of the config template
* Added support for the following configuration parameters
* * ``anon_mkdir_write_enable``
* * ``anon_other_write_enable``
* * ``download_enable``
* * ``chroot_list_enable``
* * ``file_open_mode``
* * ``ftp_data_port``
* * ``listen_port``
* * ``anon_umask``
* * ``anon_root``
* * ``ftpd_banner``
* * ``banner_file``
* * ``max_clients``
* * ``max_per_ip``
* * ``ftp_username``
* * ``guest_enable``
* * ``guest_username``
* * ``anon_world_readable_only``
* * ``ascii_download_enable``
* * ``ascii_upload_enable``
* * ``chown_uploads``
* * ``chown_username``
* * ``chroot_list_file``
* * ``secure_chroot_dir``
* * ``user_config_dir``
* * ``userlist_deny``
* * ``userlist_enable``
* * ``userlist_file``
* * ``delete_failed_uploads``
* * ``cmds_allowed``
* * ``cmds_denied``
* * ``deny_file``
* * ``hide_file``
* * ``syslog_enable``
* * ``dual_log_enable``
* * ``hide_ids``
* * ``use_localtime``
* * ``local_max_rate``
