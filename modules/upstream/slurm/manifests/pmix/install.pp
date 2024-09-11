################################################################################
# Time-stamp: <Wed 2021-03-31 00:59 svarrette>
#
# File::      <tt>pmix/install.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2019 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::pmix::install
#
# This definition takes care of installing the PMIx packages typically built
# from the slurm::pmix::build (to ensure *separate* RPMs builds have been
# produced to avoid conflicts with slurm-libpmi, which provides its own,
# incompatible versions of libpmi.so and libpmi2.so.), for a given version for
# PMIx passed as resource name.
#
# @param ensure     [String]  Default: 'present'
#          Ensure the presence (or absence) of installation
# @param builddir   [String] Default: '/root/rpmbuild/' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <builddir>/RPMS/${::architecture}
#
# @example install version 3.1.4 (latest at the time of writing)  of PMIx
#
#     slurm::pmix::install { '3.1.4':
#        ensure   => 'present',
#        builddir => "/root/rpmbuild/",
#     }
#
#
define slurm::pmix::install(
  String  $ensure   = $slurm::params::ensure,
  String  $builddir = $slurm::params::builddir,
)
{
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ '\d+[\.-]?' ])

  # $name is provided at define invocation
  $version = $name

  case $::osfamily {
    'Redhat': {
      include ::epel
      include ::yum
      $rpmdir = "${builddir}/RPMS/${::architecture}"
      $rpm = "pmix-${version}*.rpm"
      $rpmdevel = "pmix-devel-${version}*.rpm"

      case $ensure {
        'absent': {
          $cmd = "yum -y remove pmix*-${version}*"
          $check_onlyif = "test -n \"$(rpm -qa | grep -E 'pmix.*${version}')\""
          $check_unless = "test -z \"$(rpm -qa | grep -E 'pmix.*${version}')\""
        }
        default: {
          #  $cmd = "yum -y --nogpgcheck localinstall  pmix*-${version}*"
          #  $check_onlyif = "test -z \"$(rpm -qa | grep -E 'pmix.*${version}')\""
          #  $check_unless = "test -n \"$(rpm -qa | grep -E 'pmix.*${version}')\""
          Package["pmix-${version}"] {
            provider        => 'rpm',
            install_options => [ '--nodeps' ],
            source          => "${rpmdir}/${rpm}",
          }
          Package["pmix-devel-${version}"] {
            provider        => 'rpm',
            install_options => [ '--nodeps' ],
            source          => "${rpmdir}/${rpmdevel}",
          }
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Let's go (independently of the distribution)
  if $ensure == 'present' {
    package { [ "pmix-${version}", "pmix-devel-${version}" ]:
      ensure  => $ensure,
    }
  }
  else {
    #notice($cmd)
    exec { "uninstall-pmix*${version}*":
      path    => '/sbin:/usr/bin:/usr/sbin:/bin',
      command => $cmd,
      onlyif  => $check_onlyif,
      unless  => $check_unless,
      user    => 'root',
    }
  }

}
