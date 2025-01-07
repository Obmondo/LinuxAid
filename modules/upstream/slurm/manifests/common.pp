################################################################################
# Time-stamp: <Fri 2019-10-11 10:10 svarrette>
#
# File::      <tt>common.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::common
#
# Base class to be inherited by the other slurm classes, containing the common code.
#

class slurm::common {
  # Load the variables used in this module. Check the params.pp file
  require slurm::params

  # Packages required for building SLURM
  $build_required_pkgs = if $slurm::do_build {
    concat($slurm::params::pre_requisite_packages, $slurm::params::munge_extra_packages)
  } else {
    []
  }

  # Other packages for use with SLURM
  $required_pkgs = concat($build_required_pkgs, $slurm::params::extra_packages)

  $all_packages = $required_pkgs.filter |String $pkg_name| {
    # Safeguard to avoid incompatibility with other puppet modules
    !(Package[$pkg_name].defined)
  }

  package { $all_packages:
    ensure          => 'present',
    install_options => $slurm::package_install_options,
  }

  # Prepare the user and group
  group { 'slurm':
    ensure => $slurm::ensure,
    name   => $slurm::params::group,
    gid    => $slurm::gid,
  }
  user { 'slurm':
    ensure     => $slurm::ensure,
    name       => $slurm::params::username,
    uid        => $slurm::uid,
    gid        => $slurm::gid,
    comment    => $slurm::params::comment,
    home       => $slurm::params::home,
    managehome => true,
    system     => true,
    shell      => $slurm::params::shell,
  }

  # Order
  if ($slurm::ensure == 'present') {
    Group['slurm'] -> User['slurm']
  }
  else {
    User['slurm'] -> Group['slurm']
  }

  if ($slurm::manage_pam and $slurm::use_pam and ($slurm::with_slurmd or defined(Class['slurm::slurmd']))) {
    include slurm::pam
  }

  if ($slurm::with_pmix or ('pmix' in $slurm::build_with)) {
    include slurm::pmix
    # class { '::slurm::pmix':
    #   ensure            => $slurm::ensure,
    #   version           => $slurm::pmix_version,
    #   src_checksum      => $slurm::pmix_src_checksum,
    #   src_checksum_type => $slurm::pmix_src_checksum_type,
    #   srcdir            => $slurm::srcdir,
    #   builddir          => $slurm::builddir,
    # }
  }

  if ($slurm::manage_munge and $slurm::authtype =~ /munge/) {
    # include ::slurm::munge
    class { 'slurm::munge':
      ensure       => $slurm::ensure,
      create_key   => $slurm::munge_create_key,
      daemon_args  => $slurm::munge_daemon_args,
      uid          => $slurm::munge_uid,
      gid          => $slurm::munge_gid,
      key_source   => $slurm::munge_key_source,
      key_content  => $slurm::munge_key_content,
      key_filename => $slurm::munge_key_filename,
    }
    if $slurm::ensure == 'absent' and $slurm::do_package_install {
      Slurm::Install::Packages[$slurm::version] -> Class['slurm::munge']
    }
  }

  if $slurm::with_slurmdbd {
    include slurm::slurmdbd
  }
  if $slurm::with_slurmctld {
    include slurm::slurmctld
  }
  if $slurm::with_slurmd {
    include slurm::slurmd
  }
}

#}
