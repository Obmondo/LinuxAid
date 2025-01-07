################################################################################
# Time-stamp: <Thu 2022-06-30 14:42 svarrette>
#
# File::      <tt>repo/syncto.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Define: slurm::repo::syncto
#
# This definition takes care of synchronizing the control repository of the
# slurm configuration (which is cloned using the 'slurm::repo' class) toward a
# directory (typically a shared mountpoint)
#
# @param subdir      [String]
#         Specifies a source [sub]directory within the repository holding the
#         sources we wish to synchronize
# @param target      [String]
#         Target [shared] directory where to synchronize
# @param purge        [Boolean] Default: false
#          If set, rsync will use '--delete'
define slurm::repo::syncto (
  Enum['present', 'absent'] $ensure = $slurm::params::ensure,
  String                    $target = '',
  String                    $subdir = '',
  Boolean                   $purge  = false,
) {
  include slurm::params
  if !defined(Class['slurm::repo']) {
    include slurm::repo
  }

  # $name is provided at define invocation
  $to = empty($target) ? {
    true    => $name,
    default => $target,
  }

  $reponame  =  basename($slurm::repo::source, ".${slurm::repo::provider}")
  $institute = basename(dirname($slurm::repo::source))
  $from = $slurm::repo::path ? {
    ''      => "${slurm::repo::basedir}/${institute}/${reponame}",
    default => $slurm::repo::path,
  }
  rsync::put { "${to}/":
    source  => "${from}/${subdir}/",
    purge   => $purge,
    options => '-a --copy-links',
  }
}
