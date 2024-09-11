# == Define: stunnel::tun
#
# Creates a tunnel config to be started by the stunnel application on startup.
#
# === Parameters
#
# [*namevar*]
#   The namevar in this type is the title you give it when you define a resource
#   instance.  It is used for a handful of purposes; defining the name of the
#   config file and the tunnel section in the config, as well as things like
#   the PID file.
#
# [*certificate*]
#   Signed SSL certificate to be used during authentication and encryption.
#   This module is meant to work in conjuction with an already established
#   Puppet infrastructure so we are defaulting to the default location of the
#   agent certificate on Puppet Enterprise.
#
# [*private_key*]
#   In order to encrypt and decrypt things there needs to be a private_key
#   someplace among the system.  Just like certificate we use data from Puppet
#   Enterprise.
#
# [*ca_file*]
#   The CA to use to validate client certificates.  We default to that
#   distributed by Puppet Enterprise.
#
# [*crl_file*]
#   Currently OCSP is not supported in this module so in order to know if a
#   certificate has not been revoked, you will need to load a revocation list.
#   We default to the one distributed by Puppet Enterprise.
#
# [*verify*]
#   Verify peer certificate. Default is 2 for backwards compatibility with
#     this Puppet module.
#   Other values: 1 - verify peer certificate if present
#                 2 - verify peer certificate
#                 3 - verify peer with locally installed certificate
#                 default - no verify
#   See below for examples.
#
# [*ssl_version*]
#   Which SSL version you plan to enforce for this tunnel.
#   The default is TLSv1.
#
# [*chroot*]
#   To protect your host the stunnel application runs inside a chrooted
#   environment.  You must devine the location of the processes' root
#   directory.
#
# [*user*]
#   The stunnel application is capable of running each defined tunnel as a
#   different user.
#
# [*group*]
#   The stunnel application is capable of running each defined tunnel as a
#   different group.
#
# [*pid_file*]
#   Where the process ID of the running tunnel is saved.  This values needs to
#   be relative to your chroot directory.
#
# [*debug_level*]
#   The debug leve of your defined tunnels that is sent to the log.
#
# [*log_dest*]
#   The file that log messages are delivered to.
#
# [*client*]
#   If we running our tunnel in client mode.  There is a difference in stunnel
#   between initiating connections or listening for them.  Default: false.
#
# [*accept*]
#   For which host and on which port to accept connection from.
#
# [*connect*]
#  What port or host and port to connect to.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# [*chroot_mode*]
#   The mode used for a chroot dir when specified.
#   In some versions, the log file is placed under chroot, and
#   permissions may be needed to read the file.
#   Note: Should not be writable except by owner.
#   Default: '0600'
#
# === Examples
#
#   Use a cert:
#
#   stunnel::tun { 'rsyncd':
#     certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
#     private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
#     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
#     crl_file    => '/etc/puppet/ssl/crl.pem',
#     verify      => '2',
#     chroot      => '/var/lib/stunnel4/rsyncd',
#     user        => 'pe-puppet',
#     group       => 'pe-puppet',
#     client      => false,
#     accept      => '1873',
#     connect     => '873',
#   }
#
#   No cert:
#
#   stunnel::tun { 'rsyncd':
#     verify      => 'default', # default means no verify, see man stunnel.
#     chroot      => '/var/lib/stunnel4/rsyncd',
#     user        => 'pe-puppet',
#     group       => 'pe-puppet',
#     client      => false,
#     accept      => '1873',
#     connect     => '873',
#   }
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
define stunnel::tun(
  Array[Variant[String, Integer]] $connect,
  Boolean                         $ensure      = true,
  Optional[Variant[String]]       $accept      = undef,
  Boolean                         $retry       = false,
  Boolean                         $reset       = true,
  Enum['prio', 'rr']              $failover    = 'prio',
  Optional[Stdlib::Absolutepath]  $chroot      = undef,
  Optional[String]                $user        = undef,
  Optional[String]                $group       = undef,
  Optional[Stdlib::Absolutepath]  $certificate = undef,
  Optional[Stdlib::Absolutepath]  $private_key = undef,
  Optional[Stdlib::Absolutepath]  $ca_file     = undef,
  Optional[Stdlib::Absolutepath]  $ca_path     = undef,
  Optional[Stdlib::Absolutepath]  $crl_file    = undef,
  Pattern[
    /^SSLv2$|^SSLv3$|^TLSv1$|^TLSv1.1$|^TLSv1.2$/
  ]                               $ssl_version = 'TLSv1.2',
  Optional[Integer[0,4]]          $verify      = undef,
  Boolean                         $client      = false,
  # stunnel creates a PID file even though the man page says that it should not;
  # we give it a value to avoid defaulting to `/var/run/stunnel.pid`
  Optional[Stdlib::Absolutepath]  $pid_file    = "/run/stunnel-${name}.pid",
  Variant[
    Enum['emerg', 'alert', 'crit', 'err', 'warning', 'notice', 'info', 'debug'],
    Integer[0,7]]                 $debug_level = 'emerg',
  Optional[Stdlib::Absolutepath]  $log_dest    = undef,
  Boolean                         $syslog      = true,
  Stdlib::Absolutepath            $conf_dir    = lookup('stunnel::conf_dir', Stdlib::Absolutepath, undef, undef),
  Stdlib::Filemode                $chroot_mode = '0600',
) {

  include stunnel

  unless $verify == 'default' {
    if !$ssl_version {
      fail('$ssl_version must have a value if $verify is set to "default".')
    }
  }

  file { "${conf_dir}/${name}.conf":
    ensure  => ensure_present($ensure),
    content => epp("${module_name}/stunnel.conf.epp", {
      accept      => $accept,
      ca_file     => $ca_file,
      ca_path     => $ca_path,
      certificate => $certificate,
      chroot      => $chroot,
      chroot_mode => $chroot_mode,
      client      => $client.stunnel::to_yesno,
      connect     => $connect,
      crl_file    => $crl_file,
      debug_level => $debug_level,
      failover    => $failover,
      log_dest    => $log_dest,
      name        => $name,
      pid_file    => $pid_file,
      private_key => $private_key,
      reset       => $reset.stunnel::to_yesno,
      retry       => $retry.stunnel::to_yesno,
      ssl_version => $ssl_version,
      syslog      => $syslog.stunnel::to_yesno,
      user        => $user,
      group       => $group,
      verify      => $verify,
    }),
    mode    => '0644',
    owner   => '0',
    group   => '0',
    require => File[$conf_dir],
  }

  if $chroot {
    file { $chroot:
      ensure => ensure_dir($ensure),
      owner  => $user,
      group  => $group,
      mode   => $chroot_mode,
    }
  }

  service { "stunnel@${name}.service":
    ensure     => ensure_service($ensure),
    enable     => true,
    provider   => 'systemd',
    hasrestart => true,
    subscribe  => [
      File["${conf_dir}/${name}.conf"],
      Exec['systemd_reload'],
    ],
  }
}
