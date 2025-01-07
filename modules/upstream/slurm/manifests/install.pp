################################################################################
# Time-stamp: <Thu 2022-06-30 14:37 svarrette>
#
# File::      <tt>install.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::install
#
# This PRIVATE class handles the installation of SLURM
#
class slurm::install {
  include slurm
  include slurm::params

  Class['slurm::common'] -> Class['slurm::install']

  # [Eventually] download and build slurm sources
  if $slurm::do_build {
    # Download the Slurm sources
    slurm::download { $slurm::version :
      ensure        => $slurm::ensure,
      target        => $slurm::srcdir,
      checksum      => $slurm::src_checksum,
      checksum_type => $slurm::src_checksum_type,
    }

    # Now build them
    slurm::build { $slurm::version :
      ensure  => $slurm::ensure,
      srcdir  => $slurm::srcdir,
      dir     => $slurm::builddir,
      with    => $slurm::build_with,
      without => $slurm::build_without,
      require => Slurm::Download[$slurm::version],
    }
  }

  # [Eventually] Install the built packages/RPMs
  if $slurm::do_package_install {
    slurm::install::packages { $slurm::version :
      ensure    => $slurm::ensure,
      pkgdir    => $slurm::builddir,
      slurmd    => ($slurm::with_slurmd    or defined(Class['slurm::slurmd'])),
      slurmctld => ($slurm::with_slurmctld or defined(Class['slurm::slurmctld'])),
      slurmdbd  => ($slurm::with_slurmdbd  or defined(Class['slurm::slurmdbd'])),
      wrappers  => $slurm::wrappers,
      require   => $slurm::do_build ? {
        true  => Slurm::Build[$slurm::version],
        false => undef
      },
    }
  }
}
