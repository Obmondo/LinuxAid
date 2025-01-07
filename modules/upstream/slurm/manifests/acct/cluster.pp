################################################################################
# Time-stamp: <Sat 2017-09-30 01:00 svarrette>
#
# File::      <tt>acct/cluster.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::cluster
#
# This definition takes care of adding (or removing) a cluster to the slurm database.
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin and a working SLURMDBD.
# The name of this resource is expected to be the cluster name.
#
# @param ensure
#          Ensure the presence (or absence) of the entity - Default: 'present'
# @param options [Hash] Default: {}
#          Specification options -- see https://slurm.schedmd.com/sacctmgr.html
#          Elligible keys:  # Classification, Cluster, ClusterNodes,
#                             ControlHost, ControlPort, DefaultQOS,
#                             Fairshare, Flags, GrpTRESMins, GrpTRES GrpJobs,
#                             GrpMemory, GrpNodes, GrpSubmitJob, MaxTRESMins,
#                             MaxTRES, MaxJobs, MaxNodes, MaxSubmitJobs,
#                             MaxWall, NodeCount, PluginIDSelect, RPC, TRES
#
# @example Adding the cluster 'thor' to Slurm
#
#     slurm::acct::cluster { 'thor':
#     ensure    => 'present',
#   }
#
# TODO/ from the manpage, we can provide the following options to this definition
#
#
define slurm::acct::cluster (
  Enum['present', 'absent'] $ensure  = $slurm::ensure,
  Hash                      $options = {}
) {
  slurm::acct::mgr { "cluster/${name}":
    ensure  => $ensure,
    entity  => 'cluster',
    value   => $name,
    options => $options,
  }
}
