################################################################################
# Time-stamp: <Wed 2019-10-09 11:02 svarrette>
#
# File::      <tt>pmix.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2019 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::pmix
#
# This facility class handles the installation of PMIx.
# It is meant to be a simple wrapper around the slurm::pmix::* definitions
#
# @param ensure  [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param version [String] Default: 3.1.4' (see params.pp)
#          PMIx version to install
# @param srcdir [String] Default: '/usr/local/src'
#          Target directory for the downloaded sources
# @param checksum_type [String] Default: 'sha1'
#          archive file checksum type (none|md5|sha1|sha2|sh256|sha384| sha512).
# @param checksum [String] Default: see params.pp
#           archive file checksum (match checksum_type)
# @param builddir [String] Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <builddir>/RPMS/${::architecture}
# @param do_build                 [Boolean]     Default: true
#          Do we perform the build of the OpenPMIx packages from sources or not?
# @param do_package_install       [Boolean]     Default: true
#          Do we perform the install of the OpenPMIx packages or not?
#
# @example install version 3.2.3 of PMIx
#
#     slurm::pmix { '3.1.4':
#        ensure => 'present',
#        builddir => "/root/rpmbuild/",
#     }
#
class slurm::pmix (
  String  $ensure             = $slurm::params::ensure,
  String  $version            = $slurm::params::pmix_version,
  String  $srcdir             = $slurm::params::srcdir,
  String  $src_checksum       = $slurm::params::pmix_src_checksum,
  String  $src_checksum_type  = $slurm::params::pmix_src_checksum_type,
  String  $builddir           = $slurm::params::builddir,
  Boolean $do_build           = $slurm::params::do_build,
  Boolean $do_package_install = $slurm::params::do_package_install,
) {
  include slurm::params

  # Download the PMIx sources
  slurm::pmix::download { $version :
    ensure        => $ensure,
    target        => $srcdir,
    checksum      => $src_checksum,
    checksum_type => $src_checksum_type,
  }

  if $do_build {
    # Now build them
    slurm::pmix::build { $version :
      ensure  => $ensure,
      srcdir  => $srcdir,
      dir     => $builddir,
      require => Slurm::Pmix::Download[$version],
    }
  }

  if $do_package_install {
    # And install it
    slurm::pmix::install { $version :
      ensure   => $ensure,
      builddir => $builddir,
      require  => Slurm::Pmix::Build[$version],
    }
  }
}
