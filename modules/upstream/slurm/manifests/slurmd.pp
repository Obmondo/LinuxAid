################################################################################
# Time-stamp: <Wed 2021-03-31 01:00 svarrette>
#
# File::      <tt>slurmd.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::slurmd
#
# The main helper class specializing the main slurm class for setting up a
# Slurmd daemon
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::slurmd inherits slurm {
  case $facts['os']['family'] {
    'Redhat': {}
    default:  { fail("Module ${module_name} is not supported on ${facts['os']['name']}") }
  }

  include slurm::install
  include slurm::config
  Class['slurm::install'] -> Class['slurm::config']

  if $slurm::manage_firewall {
    slurm::firewall { String($slurm::slurmdport):
      ensure => $slurm::ensure,
    }
    slurm::firewall { String($slurm::srunportrange):
      ensure => $slurm::ensure,
    }
  }

  if $slurm::ensure == 'present' {
    File <| tag == 'slurm::configfile' |> {
      require => File[$slurm::configdir],
    }
  }

  if $slurm::service_manage == true {
    File <| tag == 'slurm::configfile' |> {
      notify  +> Service['slurmd'],
    }

    service { 'slurmd':
      ensure     => ($slurm::ensure == 'present'),
      enable     => ($slurm::ensure == 'present'),
      name       => $slurm::params::servicename,
      pattern    => $slurm::params::processname,
      hasrestart => $slurm::params::hasrestart,
      hasstatus  => $slurm::params::hasstatus,
      require    => Class['slurm::config'],
    }

    if ($slurm::with_slurmctld or defined(Class['slurm::slurmctld'])) {
      Service['slurmctld'] -> Service['slurmd']
    }
  }
}
