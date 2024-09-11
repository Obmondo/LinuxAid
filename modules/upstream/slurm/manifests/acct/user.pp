################################################################################
# Time-stamp: <Thu 2017-09-07 19:32 svarrette>
#
# File::      <tt>acct/user.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::user
#
# This definition takes care of adding (or removing) a login name into Slurm.
# Only lowercase usernames are supported.
#
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin
# and a working SLURMDBD.
# The name of this resource is expected to be the qos name.
#
# @param ensure [String]  Default: 'present'
#          Ensure the presence (or absence) of the entity
# @param $defaultaccount [String]
#          Identify the default bank account name to be used for a job if none is
#          specified at submission time.
# @param options [Hash] Default: {}
#          Specification options -- see https://slurm.schedmd.com/sacctmgr.html
#          Elligible keys:
#
define slurm::acct::user(
  String  $ensure         = $slurm::params::ensure,
  String  $defaultaccount = '',
  Hash    $options        = {},
)
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  $default_options = empty($defaultaccount) ? {
    true    => {},
    default => { 'DefaultAccount' => $defaultaccount, }
  }
  slurm::acct::mgr { "user/${name}":
    ensure  => $ensure,
    entity  => 'user',
    value   => $name,
    options => merge($default_options, $options),
  }
}
