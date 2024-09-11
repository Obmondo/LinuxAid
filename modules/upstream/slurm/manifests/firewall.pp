################################################################################
# Time-stamp: <Thu 2022-06-30 14:33 svarrette>
#
# File::      <tt>firewall.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::firewall
#
# This definition takes care of firewall aspects for SLURM
#
#
define slurm::firewall(
  String $ensure    = 'present',
  String  $zone     = 'public',
  $port             = undef,
  String  $seltype  = '',
  String  $protocol = 'tcp',
)
{
  include ::slurm::params
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  if (($::osfamily != 'RedHat') or (versioncmp($facts['os']['release']['major'], '7') < 0)) {
    fail("Module ${module_name} is not supported on ${::operatingsystem}")
  }

  # $name is provided at define invocation
  $port_range = $port ? {
    undef   => $name,
    default => $port,
  }

  if (defined(Class['firewalld'])) {
    ###### CentOS/RHEL 7 with firewalld
    firewalld_port { "slurm-${port_range}":
      ensure   => $ensure,
      zone     => $zone,
      port     => $port_range,
      protocol => $protocol,
    }
    if (defined(Class['selinux']) and $facts['os']['selinux']['enabled'] and !empty($seltype)) {
      $array_range = split($port_range, '-')
      selinux::port { "slurm-allow-${seltype}-port-${port_range}":
        ensure     => $ensure,
        seltype    => $seltype,
        protocol   => $protocol,
        port_range => [ ($array_range[0]+0), ($array_range[1]+0) ],
      }
    }
  }
}
