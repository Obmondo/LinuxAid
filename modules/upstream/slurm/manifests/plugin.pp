################################################################################
# Time-stamp: <Thu 2022-06-30 14:39 svarrette>
#
# File::      <tt>plugin.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::plugin
#
# This definition takes care of managing SLURM plugins.
#
# @param ensure
#          Ensure the presence (or absence) of building - Default: 'present'
# @param path
#          Target directory for the downloaded sources - Default '/usr/local/src'
# @param content [String]      Default: undef
#           The desired contents of a topology file, as a string. This attribute is
#           mutually exclusive with topology_source and topology_target.
# @param source          [String]      Default: undef
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with {content,target}.
# @param target          [String]      Default: undef
#          Target link path
#
#
define slurm::plugin (
  Enum['present', 'absent']      $ensure  = $slurm::params::ensure,
  Optional[Stdlib::Absolutepath] $path    = '/usr/local/src',
  Optional[Stdlib::Absolutepath] $target  = undef,
  Optional[String]               $source  = undef,
  Optional[String]               $content = undef,
) {
  include slurm::params

  # $name is provided at define invocation
  # if $name =~ /slurm-(.*)\.tar\.bz2/ {  # Full archive name provided
  #   $archive = $name
  #   $version = $1
  # }
  # elsif ($name =~ /\d+[\.-]?/ ) {       # only the version was provided
  #   $version = $name
  #   $archive = "slurm-${version}.tar.bz2"
  # }
  # else { fail("Wrong specification for ${module_name}") }
  # # URL from where to download the sources
  # $url =  "${slurm::params::download_baseurl}/${archive}"
  # # Absolute path to the downloaded source file
  # $path =  "${target}/${archive}"

  # # Download the sources using puppet-archive module
  # archive { $archive:
  #   ensure          => $ensure,
  #   path            => $path,
  #   source          => $url,
  #   user            => $slurm::params::username,
  #   group           => $slurm::params::group,
  #   checksum_type   => $checksum_type,
  #   checksum_verify => ($checksum_verify or ! empty($checksum)),
  #   checksum        => $checksum,
  #   cleanup         => false,
  #   extract         => false,
  #   creates         => $path,
  # }
}
