################################################################################
# Time-stamp: <Fri 2019-10-11 01:06 svarrette>
#
# File::      <tt>config/cgroup.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::cgroup
#
# This PRIVATE class handles the Slurm configuration file for the cgroup support
# i.e. 'cgroup.conf'
#
# More details: see <https://slurm.schedmd.com/cgroup.conf.html>
#
# For general Slurm Cgroups information, see the Cgroups Guide at
# <https://slurm.schedmd.com/cgroups.html>.
#
class slurm::config::cgroup inherits slurm::config {
  # NOTE: Debian and derivatives (e.g. Ubuntu) usually exclude the memory and
  # memsw (swap) cgroups by default. To include them, add the following
  # parameters to the kernel command line: cgroup_enable=memory swapaccount=1
  # This is not covered in this class

  $cgroup_content = $slurm::cgroup_content ? {
    undef   => $slurm::cgroup_source ? {
      undef   => $slurm::cgroup_target ? {
        undef   => template('slurm/cgroup.conf.erb'),
        default => $slurm::cgroup_content,
      },
      default => $slurm::cgroup_content
    },
    default => $slurm::cgroup_content,
  }
  $ensure = $slurm::cgroup_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }
  $cgroup_filename          = "${slurm::configdir}/${slurm::params::cgroup_configfile}"
  $allowed_devices_filename = "${slurm::configdir}/${slurm::params::cgroup_alloweddevices_configfile}"

  # cgroup.conf
  file { $slurm::params::cgroup_configfile:
    ensure  => $ensure,
    path    => $cgroup_filename,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $cgroup_content,
    source  => $slurm::cgroup_source,
    target  => $slurm::cgroup_target,
    tag     => 'slurm::configfile',
  }

  # ~~[eventually] cgroup_allowed_devices_file.conf~~
  # UPDATE Slurm > 18.08: cgroup_allowed_devices_file.conf is no longer required.
  # By default all devices are allowed and GRES, that are associated with a
  # device file, that are not requested are restricted.
  # if !empty($slurm::cgroup_alloweddevices) {
  #   file { $slurm::params::cgroup_alloweddevices_configfile:
  #     ensure  => $slurm::ensure,
  #     path    => $allowed_devices_filename,
  #     owner   => $slurm::username,
  #     group   => $slurm::group,
  #     mode    => $slurm::params::configfile_mode,
  #     content => template('slurm/cgroup_allowed_devices_file.conf.erb'),
  #     tag     => 'slurm::configfile',
  #   }
  # }
}
