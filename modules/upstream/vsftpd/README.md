# vsftpd Module

## Overview

This module installs, configures and manages the vsftpd FTP server.
Original module by [aneesh](https://github.com/aneesh-c/puppet-vsftpd).
Forked and improved by [pseiler](https://github.com/pseiler)

## Description
A more Puppety way of managing the vsftpd daemon. Where possible, as many of
the configuration options have remained the same with a couple of notable exceptions:
 * Booleans are now used instead of `YES`/`NO`.
   e.g. `local_enable=YES` == `local_enable => true`, `local_enable=NO` == `local_enable => false`.
 * parameter values seperated by a comma are now arrays. This also applies to parameters with surrounding curly brackets.
   These parameters are affected: `cmds_allowed`, `cmds_denied`, `deny_file` and `hide_file`. Examples below

All configuration parameters *vsftpd.conf* supports, are also supported by this module.
Please read the manpage of vsftpd for more informations about every parameter.

These additional parameters have a default and can be overwritten
* ``package_name`` (String) - The name of the package from your package manager for your operating system
* ``service_name`` (String) - the service name. (e.g. systemd service, etc...)
* ``config_path`` (String) - The path where *vsftpd.conf* should be written to
* ``template`` (String) - path to the erb template used, if you want to provide your own
* ``manage_service`` (Boolean) - Control if the service should be started and enabled
The defaults can be found in the *params.pp*

## Usage
Default configuration (pretty empty configuration file with no parameter set is written and not recommended):

```puppet
include vsftpd
```

Custom configuration:

```puppet
class { 'vsftpd':
    anonymous_enable         => false,
    anon_mkdir_write_enable  => false,
    anon_other_write_enable  => false,
    local_enable             => true,
    download_enable          => true,
    write_enable             => true,
    local_umask              => '022',
    dirmessage_enable        => true,
    xferlog_enable           => true,
    connect_from_port_20     => true,
    xferlog_std_format       => true,
    chroot_local_user        => true,
    chroot_list_enable       => true,
    file_open_mode           => '0666'
    ftp_data_port            => 20,
    listen                   => true,
    listen_ipv6              => false,
    listen_port              => 21,
    pam_service_name         => 'vsftpd',
    tcp_wrappers             => true,
    allow_writeable_chroot   => true,
    pasv_enable              => true,
    pasv_min_port            => 1024,
    pasv_max_port            => 1048,
    pasv_address             => '127.0.0.1',
}
```
A few advanced Configuration parameter examples

```puppet
    anon_umask               => '077',
    anon_root                => '/var/ftp/anonymous',
    anon_max_rate            => 0,
    ftpd_banner              => 'My custom banner',
    banner_file              => '/etc/vsftpd/my_banner.txt',
    max_clients              => 0,
    max_per_ip               => 0,
    ftp_username             => 'ftp',
    guest_enable             => false,
    guest_username           => 'ftp',
    anon_world_readable_only => false,
    ascii_download_enable    => false,
    ascii_upload_enable      => false,
    chown_uploads            => true,
    chown_username           => 'linux',
    chroot_list_file         => '/etc/vsftpd/my_chroot_list',
    secure_chroot_dir        => '/usr/share/empty',
    user_config_dir          => '/etc/vsftpd/user_config',
    userlist_deny            => true,
    userlist_enable          => true,
    userlist_file            => '/etc/vsftpd/my_userlist',
    delete_failed_uploads    => false,
    cmds_allowed             => ['PASV','RETR','QUIT'],
    cmds_denied              => ['PASV','RETR','QUIT'],
    deny_file                => ['*.mp3','*.mov','.private'],
    hide_file                => ['*.mp3','.hidden','hide*','h?'],
    syslog_enable            => false,
    dual_log_enable          => false,
    hide_ids                 => false,
    use_localtime            => false,
    local_max_rate           => 0,
```

SSL integration (not a rocksolid configuration)

```puppet
    rsa_cert_file           => '/etc/ssl/private/vsftpd.pem',
    rsa_private_key_file    => '/etc/ssl/private/vsftpd.pem',
    ca_certs_file            => '/etc/ssl/private/ca.pem',
    ssl_enable              => true,
    allow_anon_ssl          => true,
    force_local_data_ssl    => true,
    force_local_logins_ssl  => true,
    ssl_tlsv1               => true,
    ssl_sslv2               => false,
    ssl_sslv3               => false,
    require_ssl_reuse       => true,
    ssl_ciphers             => 'HIGH',
```
