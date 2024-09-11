################################################################################
# Time-stamp: <Sat 2017-09-30 01:03 svarrette>
#
# File::      <tt>acct/qos.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::qos
#
# This definition takes care of adding (or removing) a Quality of Service (QOS)
# for each job submitted to Slurm.
# For more details: see <https://slurm.schedmd.com/qos.html>
#
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin
# and a working SLURMDBD.
# The name of this resource is expected to be the qos name.
#
# @param ensure      [String]            Default: 'present'
#          Ensure the presence (or absence) of the entity
# @param priority    [Integer]           Default: 0
# @param options     [Hash]              Default: {}
#          Specification options -- see https://slurm.schedmd.com/sacctmgr.html
#          Elligible keys:  Description=, Flags=, GraceTime=, GrpJobs=,
#                           GrpSubmitJob=, GrpTRES=, GrpTRESMins=, GrpWall=,
#                           MaxJobs=, MaxSubmitJobsPerUser=, MaxTRESMins=,
#                           MaxTRESPerJob=, MaxTRESPerNode=, MaxTRESPerUser=,
#                           MaxWall=, Names=, Preempt=, PreemptMode=,
#                           Priority=, UsageFactor=, and UsageThreshold=
#
# @example Adding the qos 'qos-interactive' to Slurm
#
# slurm::acct::qos { 'qos-interactive':
  #   ensure    => 'present',
  #   priority  => 20,
  #   options   => {
    #     preempt  => 'qos-besteffort',
    #     grpnodes => 30,
    #   }
  # }
#
# this will run the following command:
#   sacctmgr -i add qos qos-interactive Priority=20 Preempt=qos-besteffort Grpnodes=30
#
# @example
define slurm::acct::qos(
  String  $ensure   = $slurm::params::ensure,
  Integer $priority = 0,
  String  $content  = '',
  Hash    $options  = {},
)
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  $default_options = {
    'priority' => $priority,
  }
  if $options == undef {
    $real_options = $default_options
  }
  elsif $options.is_a(String) {
    $real_options = ($options =~ /[pP]riority=/) ? {
      true    => { 'content' => $options, },
      default => merge($default_options, { 'content' => $options }),
    }
  }
  elsif $options.is_a(Array) {
    $real_options = merge($default_options, { content => join($options, ' ') })
  }
  else {
    $real_options = merge($default_options, $options)
  }
  slurm::acct::mgr { "qos/${name}":
    ensure  => $ensure,
    entity  => 'qos',
    value   => $name,
    options => $real_options,
  }
}
