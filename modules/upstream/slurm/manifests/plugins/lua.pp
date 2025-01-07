################################################################################
# Time-stamp: <Thu 2022-06-30 14:42 svarrette>
#
# File::      <tt>plugins/lua.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::plugins::lua
#
# This PRIVATE class handles the configuration of Job Submit plugin 'lua' i.e.
# of the file 'job_submit.lua'
# Ex: https://github.com/SchedMD/slurm/blob/master/contribs/lua/job_submit.lua
#
# More details on <https://slurm.schedmd.com/slurm.conf.html>
#
class slurm::plugins::lua inherits slurm::plugins {
  $lua_content = $slurm::lua_content ? {
    undef   => $slurm::lua_source ? {
      undef   => $slurm::lua_target ? {
        undef   => template('slurm/job_submit.lua.erb'),
        default => $slurm::lua_content,
      },
      default => $slurm::lua_content
    },
    default => $slurm::lua_content,
  }
  $ensure = $slurm::lua_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  $filename = "${slurm::configdir}/${slurm::params::job_submit_lua}"

  file { $slurm::params::job_submit_lua:
    ensure  => $ensure,
    path    => $filename,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $lua_content,
    source  => $slurm::lua_source,
    target  => $slurm::lua_target,
    tag     => 'slurm::configfile',
    require => File[$slurm::configdir],
  }
}
