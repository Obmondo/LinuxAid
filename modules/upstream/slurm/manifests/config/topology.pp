################################################################################
# Time-stamp: <Thu 2022-06-30 14:41 svarrette>
#
# File::      <tt>config/topology.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::topology
#
# This PRIVATE class handles the Slurm configuration file for defining the network
# topology  i.e. 'topology.conf'
#
# More details: see <https://slurm.schedmd.com/topology.conf.html>
#
class slurm::config::topology inherits slurm::config {
  $topology_content = $slurm::topology_content ? {
    undef   => $slurm::topology_source ? {
      undef   => $slurm::topology_target ? {
        undef   => template('slurm/topology.conf.erb'),
        default => $slurm::topology_content,
      },
      default => $slurm::topology_content
    },
    default => $slurm::topology_content,
  }
  $ensure = $slurm::topology_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  if  $slurm::topology == 'tree' {
    $topology_filename = "${slurm::configdir}/${slurm::params::topology_configfile}"
    file { $slurm::params::topology_configfile:
      ensure  => $ensure,
      path    => $topology_filename,
      owner   => $slurm::username,
      group   => $slurm::group,
      mode    => $slurm::params::configfile_mode,
      content => $topology_content,
      source  => $slurm::topology_source,
      target  => $slurm::topology_target,
      tag     => 'slurm::configfile',
    }
  }
}
