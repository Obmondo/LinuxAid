################################################################################
# Time-stamp: <Fri 2019-10-11 10:00 svarrette>
#
# File::      <tt>download.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::download
#
# This definition takes care of downloading the SLURM sources for a given version
# (passed as name to this resource) and placing them into $target directory.
# You can also invoke this definition with the full archive filename i.e.
# slurm-<version>.tar.bz2.
#
# @param ensure
#          Ensure the presence (or absence) of building - Default: 'present'
# @param target [String] Default: '/usr/local/src'
#          Target directory for the downloaded sources
# @param checksum [String] Default: ''
#           archive file checksum (match checksum_type)
## @param checksum_type [String] Default: 'sha1'
#          archive file checksum type (none|md5|sha1|sha2|sh256|sha384| sha512).
# @param checksum_verify [Boolean] Default: false
#          whether checksum will be verified (true|false).

# @example Downloading version 19.05.3-2 of SLURM
#
#     slurm::download { '19.05.3-2':
#        ensure        => 'present',
#        checksum      => '6fe2c6196f089f6210d5ba79e99b0656f5a527b4',
#        checksum_type => 'sha1',
#        target        => '/usr/local/src/',
#   }
#
define slurm::download (
  Enum['present', 'absent'] $ensure          = $slurm::params::ensure,
  String                    $target          = $slurm::params::srcdir,
  String                    $checksum        = '',
  String                    $checksum_type   = $slurm::params::src_checksum_type,
  Boolean                   $checksum_verify = false,
) {
  include slurm::params

  # $name is provided at define invocation
  if $name =~ /slurm-(.*)\.tar\.bz2/ { # Full archive name provided
    $archive = $name
    $version = $1
  }
  elsif ($name =~ /\d+[\.-]?/ ) { # only the version was provided
    $version = $name
    $archive = "slurm-${version}.tar.bz2"
  }
  else { fail("Wrong specification for ${module_name}") }

  # URL from where to download the sources
  $url = "${slurm::params::download_baseurl}/${archive}"
  # Absolute path to the downloaded source file
  $path =  "${target}/${archive}"

  $real_checksum_type = empty($checksum) ? {
    true    => 'none',
    default => $checksum_type
  }
  # notice("checksum      = ${checksum}")
  # notice("checksum_type = ${real_checksum_type}")

  # Download the sources using puppet-archive module
  archive { $archive:
    ensure          => $ensure,
    path            => $path,
    source          => $url,
    user            => $slurm::params::username,
    group           => $slurm::params::group,
    checksum_type   => $real_checksum_type,
    checksum_verify => ($checksum_verify or ! empty($checksum)),
    checksum        => $checksum,
    cleanup         => false,
    extract         => false,
    creates         => $path,
  }
  if $ensure == 'absent' {
    file { $path:
      ensure  => $ensure,
      require => Archive[$archive],
    }
  }
}
