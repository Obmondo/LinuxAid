################################################################################
# Time-stamp: <Thu 2022-06-30 14:41 svarrette>
#
# File::      <tt>config/plugstack.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2019 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::plugstack
#
# This PRIVATE class handles the Slurm SPANK configuration file i.e. 'plugstack.conf'
#
# Documentation: https://slurm.schedmd.com/spank.html
#
# SPANK provides a very generic interface for stackable plug-ins which may be
# used to dynamically modify the job launch code in Slurm. SPANK plugins may be
# built without access to Slurm source code. They need only be compiled against
# Slurm's spank.h header file, added to the SPANK config file plugstack.conf,
# and they will be loaded at runtime during the next job launch
#
class slurm::config::plugstack inherits slurm::config {
  $plugstack_content = $slurm::plugstack_content ? {
    undef   => $slurm::plugstack_source ? {
      undef   => $slurm::plugstack_target ? {
        undef   => template('slurm/plugstack.conf.erb'),
        default => $slurm::plugstack_content,
      },
      default => $slurm::plugstack_content
    },
    default => $slurm::plugstack_content,
  }
  $ensure = $slurm::plugstack_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  $plugstack_filename = "${slurm::configdir}/${slurm::params::plugstack_configfile}"

  file { $slurm::params::plugstack_configfile:
    ensure  => $ensure,
    path    => $plugstack_filename,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $plugstack_content,
    source  => $slurm::plugstack_source,
    target  => $slurm::plugstack_target,
    tag     => 'slurm::configfile',
  }
}
