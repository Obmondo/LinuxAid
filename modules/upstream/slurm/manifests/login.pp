################################################################################
# Time-stamp: <Fri 2019-02-01 15:02 svarrette>
#
# File::      <tt>slurmd.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::login
#
# The main helper class specializing the main slurm class for setting up a
# Login node
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::login inherits slurm
{
  case $::osfamily {
    'Redhat': { }
    default:  { fail("Module ${module_name} is not supported on ${::operatingsystem}") }
  }

  include ::slurm::install
  include ::slurm::config
  Class['slurm::install'] -> Class['slurm::config']

  if $slurm::ensure == 'present' {
    File <| tag == 'slurm::configfile' |> {
      require => File[$slurm::configdir],
    }
  }

}
