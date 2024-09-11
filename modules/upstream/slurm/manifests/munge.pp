################################################################################
# Time-stamp: <Thu 2022-06-30 14:38 svarrette>
#
# File::      <tt>munge.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::munge
#
# MUNGE (MUNGE Uid 'N' Gid Emporium) is an authentication service for creating
# and validating credentials. It is designed to be highly scalable for use in an
# HPC cluster environment.
#  It allows a process to authenticate the UID and GID of another local or
# remote process within a group of hosts having common users and groups. These
# hosts form a security realm that is defined by a shared cryptographic key.
# Clients within this security realm can create and validate credentials without
# the use of root privileges, reserved ports, or platform-specific methods.
#
# For more information, see https://github.com/dun/munge
#
# This Puppet class is responsible for setting up a working Munge environment to
# be used by the SLURM daemons.
#
# See https://slurm.schedmd.com/authplugins.html
#
# @param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of the Munge service
# @param create_key   [Boolean] Default: true
#          Whether or not to generate a new key if it does not exists
# @param daemon_args  [Array] Default: []
#          Set the content of the DAEMON_ARGS variable, which permits to set
#          additional command-line options to the daemon. For example, this can
#          be used to override the location of the secret key (--key-file) or
#          set the number of worker threads (--num-threads) See
#          https://github.com/dun/munge/wiki/Installation-Guide#starting-the-daemon
# @param gid [Integer] Default: 992
#          GID of the munge group
# @param key_content  [String] Default: undef
#          The desired contents of a file, as a string. This attribute is mutually
#          exclusive with source and target.
# @param key_filename [String] Default: '/etc/munge/munge.key'
#          The secret key filename
# @param key_source   [String] Default: undef
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with content.
#          The normal form of a puppet: URI is
#                  puppet:///modules/<MODULE NAME>/<FILE PATH>
# @param uid [Integer] Default: 992
#          UID of the munge user
#
# /!\ We assume the RPM 'slurm-munge' has been already installed -- this class
# does not care about it
#
class slurm::munge(
  String  $ensure         = $slurm::params::ensure,
  Boolean $create_key     = $slurm::params::munge_create_key,
  Array $daemon_args      = $slurm::params::munge_daemon_args,
  Integer $uid            = $slurm::params::munge_uid,
  Integer $gid            = $slurm::params::munge_gid,
  String $key_filename    = $slurm::params::munge_key,
  $key_source             = undef,
  $key_content            = undef,
  Boolean $service_manage = $slurm::service_manage,
)
inherits slurm::params
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  #validate_legacy('Boolean', 'validate_bool', $create_key)

  if ($::osfamily == 'RedHat') {
    include ::epel
  }

  # Order
  if ($ensure == 'present') {
    Group['munge'] -> User['munge'] -> Package['munge']
  }
  else {
    Package['munge'] -> User['munge'] -> Group['munge']
  }

  # Install the required packages
  package { 'munge':
    ensure => $ensure,
    name   => $slurm::params::munge_package,
  }
  $slurm::params::munge_extra_packages.each |String $pkg| {
    # Safeguard to avoid incompatibility with other puppet modules
    if (!defined(Package[$pkg])) {
      package { $slurm::params::munge_extra_packages:
        ensure  => $ensure,
        require => Package['munge'],
      }
    }
  }
  # Prepare the user and group
  group { 'munge':
    ensure => $ensure,
    name   => $slurm::params::munge_group,
    gid    => $gid,
  }
  user { 'munge':
    ensure     => $ensure,
    name       => $slurm::params::munge_username,
    uid        => $uid,
    gid        => $gid,
    comment    => $slurm::params::munge_comment,
    home       => $slurm::params::munge_home,
    managehome => true,
    system     => true,
    shell      => $slurm::params::munge_shell,
  }

  if $ensure == 'present' {
    file { [ $slurm::params::munge_configdir, $slurm::params::munge_logdir ]:
      ensure  => 'directory',
      owner   => $slurm::params::munge_username,
      group   => $slurm::params::munge_group,
      mode    => '0700',
      require => Package['munge'],
    }
    file { $slurm::params::munge_piddir:
      ensure  => 'directory',
      owner   => $slurm::params::munge_username,
      group   => $slurm::params::munge_group,
      mode    => '0755',
      require => Package['munge'],
    }
  }
  else {
    file {
      [
        $slurm::params::munge_configdir,
        $slurm::params::munge_logdir,
        $slurm::params::munge_piddir,
      ]:
        ensure => $ensure,
        force  => true,
    }
  }

  # Create the key if needed
  if ($create_key and $ensure == 'present') {
    class { '::rngd':
      hwrng_device => '/dev/urandom',
    }
    exec { "create Munge key ${slurm::params::munge_key}":
      path    => '/sbin:/usr/bin:/usr/sbin:/bin',
      command => "dd if=/dev/urandom bs=1 count=1024 > ${key_filename}", # OR "create-munge-key",
      unless  => "test -f ${key_filename}",
      user    => 'root',
      before  => File[$key_filename],
      require => [
        File[dirname($key_filename)],
        Package['munge'],
        Class['::rngd']
      ],
    }
  }
  # ensure the munge key /etc/munge/munge.key
  file { $key_filename:
    ensure  => $ensure,
    owner   => $slurm::params::munge_username,
    group   => $slurm::params::munge_group,
    mode    => '0400',
    content => $key_content,
    source  => $key_source,
  }

  # Eventually prepare /etc/{default,sysconfig}/munge
  if ($key_filename == '/etc/munge/munge.key') {
    $options = $daemon_args
  }
  else {
    $options = concat($daemon_args, "--key-file ${key_filename}")
  }
  file { $slurm::params::munge_default_sysconfig:
    ensure  => $ensure,
    owner   => $slurm::params::munge_username,
    group   => $slurm::params::munge_group,
    mode    => '0644',
    content => template('slurm/munge_sysconfig.erb'),
  }

  if $service_manage == true {
    # Run munge service
    service { 'munge':
      ensure     => ($ensure == 'present'),
      name       => $slurm::params::munge_servicename,
      enable     => ($ensure == 'present'),
      pattern    => $slurm::params::munge_processname,
      hasrestart => $slurm::params::hasrestart,
      hasstatus  => $slurm::params::hasstatus,
      require    => [
        Package['munge'],
        File[$key_filename],
        File[$slurm::params::munge_configdir],
        File[$slurm::params::munge_logdir],
        File[$slurm::params::munge_piddir]
      ],
      subscribe  => File[$key_filename],
    }
  }
}
