################################################################################
# Time-stamp: <Thu 2017-09-07 15:30 svarrette>
#
# File::      <tt>acct/account.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::account
#
# This definition takes care of adding (or removing) a Slurm bank account,
# typically specified at job submit time using the --account= option. These may
# be arranged in a hierarchical fashion, for example accounts chemistry and
# physics may be children of the account science. The hierarchy may have an
# arbitrary depth.
#
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin
# and a working SLURMDBD.
# The name of this resource is expected to be the qos name.
#
# @param ensure [String]  Default: 'present'
#          Ensure the presence (or absence) of the entity
# @param cluster [String] Default: 'cluster'
#          Cluster name on which the specified resources are to be available
# @param options [Hash] Default: {}
#          Specification options -- see https://slurm.schedmd.com/sacctmgr.html
#          Elligible keys: Clusters=, DefaultQOS=, Description=, Fairshare=,
#                          GrpTRESMins=, GrpTRES=, GrpJobs=, GrpMemory=,
#                          GrpNodes=, GrpSubmitJob=, GrpWall=, MaxTRESMins=,
#                          MaxTRES=, MaxJobs=, MaxNodes=, MaxSubmitJobs=,
#                          MaxWall=, Names=, Organization=, Parent=,
#                          and QosLevel=
define slurm::acct::account(
  String $ensure  = $slurm::params::ensure,
  String $cluster = '',
  Hash   $options = {},
)
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  $real_clustername = empty($slurm::clustername) ? {
    true    => '',
    default => $slurm::clustername,
  }
  $default_options = empty($real_clustername) ? {
    true    => {},
    default => { 'cluster' => $real_clustername, },
  }
  slurm::acct::mgr { "acccount/${name}":
    ensure  => $ensure,
    entity  => 'account',
    value   => $name,
    options => merge($default_options, $options),
  }
}
