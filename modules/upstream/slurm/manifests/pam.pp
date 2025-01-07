################################################################################
# Time-stamp: <Thu 2022-06-30 14:38 svarrette>
#
# File::      <tt>pam.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::pam
#
# Setup Pluggable Authentication Modules (PAM) (i.e. the module 'pam_slurm') for slurmd,
# i.e. /etc/pam.d/slurm and
# See https://slurm.schedmd.com/faq.html#pam
#
# == Parameters
#
# @param ensure
#        Ensure the presence (or absence) of slurm::pam - Default: 'present'
# @param allowed_users    [Array]  Default: []
#        Manage login access (see PAM_ACCESS(8)) in addition to 'root'
# @param content [String] Default: see 'templates/pam_slurm.erb'
#        Content of /etc/pam.d/slurm
# @param ulimits          [Hash]
#          Default:  {
#                      'memlock' => 'unlimited',
#                      'stack'   => 'unlimited',
#                      'nproc'   => 10240,
#                     }
# @param ulimits_source   [String]
#        Source file for /etc/security/limits.d/80_slurm.conf
# @param use_pam_slurm_adopt [Boolean] Default: false
#        Whether or not use the pam_slurm_adopt  module (to Adopt incoming
#        connections into jobs) -- see
#        https://github.com/SchedMD/slurm/tree/master/contribs/pam_slurm_adopt
#
# /!\ We assume the RPM 'slurm-pam_slurm' has been already installed
#
class slurm::pam (
  Enum['present', 'absent'] $ensure              = $slurm::params::ensure,
  Array                     $allowed_users       = $slurm::params::pam_allowed_users,
  String                    $configfile          = $slurm::params::pam_configfile,
  String                    $content             = $slurm::params::pam_content,
  Hash                      $ulimits             = $slurm::params::ulimits,
  Optional[String]          $ulimits_source      = undef,
  Boolean                   $use_pam_slurm_adopt = $slurm::params::use_pam_slurm_adopt,
)
inherits slurm::params {
  # PAM access
  # Detect vagrant environment to include 'vagrant' in the list of allowed host otherwise
  # the application of this class will prevent the vagrant user to work as expected
  # Trick is to detect ::is_virtual facter + the presence of the /vagrant directory
  # See custom fact 'lib/facter/is_vagrant.rb'
  $default_allowed_users = $facts['is_vagrant'] ? {
    true    => ['root', 'vagrant'],
    default => ['root'],
  }
  $__allowed_users = empty($allowed_users) ? {
    true    => $default_allowed_users,
    default => concat( $allowed_users, $default_allowed_users),
  }
  #notice($__allowed_users)
  # if (! defined(Class['pam'])) {
  #   class { '::pam':
  #     allowed_users => $__allowed_users,
  #   }
  #   # the above class will lead to sssd errors on Redhat systems
  #   # you might want to enforce the installation of the sssd package in this case
  #   if $::osfamily == 'RedHat' and !defined(Package['sssd']) {
  #     package { 'sssd':
  #       ensure => 'present',
  #     }
  #   }
  # }

  # Establish a PAM configuration file for slurm /etc/pam.d/slurm
  # pam::service { $slurm::params::pam_servicename:
  #   ensure  => $ensure,
  #   content => $content,
  # }
  #
  if !defined(File[$configfile]) {
    file { $configfile:
      ensure  => $ensure,
      content => $content,
    }
  }

  if ($use_pam_slurm_adopt) {
    # TODO:
    notice('use pam_slurm_adopt')
  }

  # PAM limits
  # Ex: Update PAM MEMLOCK limits (required for MPI) + nproc
  include limits

  if $ulimits_source != undef {
    file { "${limits::limits_dir}/50_slurm.conf":
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => $ulimits_source,
    }
    # ulimit::rule { 'slurm':
    #   ensure => $ensure,
    #   source => $ulimits_source,
    # }
  }
  else {
    $ulimits.each |String $item, $value| {
      limits::limits { "*/${item}":
        ensure => $ensure,
        both   => $value,
      }
      # ulimit::rule { "slurm-${item}":
      #   ensure        => $ensure,
      #   ulimit_domain => '*',
      #   ulimit_type   => [ 'soft', 'hard' ],
      #   ulimit_item   => $item,
      #   ulimit_value  => $value,
      # }
    }
  }
}
