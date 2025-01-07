################################################################################
# Time-stamp: <Wed 2020-09-23 20:46 svarrette>
#
# File::      <tt>acct/mgr.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::mgr
#
# Generic wrapper for all sacctmgr commands
# See https://slurm.schedmd.com/sacctmgr.html
#
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin
# and a working SLURMDBD.
#
# @param ensure
#          Ensure the presence (or absence) of the cluster - Default: 'present'
# @param entity
#          the entity to consider for the name of this resource.
#          Elligible values in [ 'account',
#                                'association',
#                                'cluster',
#                                'coordinator',
#                                'event',
#                                'job',
#                                'qos',
#                                'Resource',
#                                'RunawayJobs',
#                                'stats',
#                                'transaction',
#                                'user',
#                                'wckeys', ]
# @param value   [String]
#          Value to associate to the entity. Uses $name by default
# @param content   [String]    Default: ''
#          Eventual content as a string for the specifications of the entity.
#          You probably SHOULDN'T mix this with the options
# @param options     [Hash]    Default: {}
#          Specification options, preferably as a hash -- depends on the entity
#          See https://slurm.schedmd.com/sacctmgr.html
#
define slurm::acct::mgr (
  Enum['present','absent'] $ensure  = $slurm::params::ensure,
  Slurm::Entity            $entity  = '',
  String                   $value   = '',
  String                   $content = '',
  Optional[Hash]           $options = undef,
) {
  include slurm
  include slurm::params

  $action = $ensure ? {
    'absent' => 'del',
    default  => 'add',
  }
  $real_name = empty($value) ? {
    true    => $name,
    default => $value,
  }
  $cmd_options = ($options == undef) ? {
    true    => [],
    default => ($options.is_a(String) or $options.is_a(Array)) ? {
      true    => flatten([$options]),
      default => $options.map |$k, $v| {
        $key = ($k =~ /[A-Z]/) ? {
          true    => $k,
          default => camelcase($k),
        }
        if ($k == 'content') {
          $v
        }
        else {
          join([$key, $v], '=')
        }
      },
    }
  }
  $opts = empty($content) ? {
    true    => join($cmd_options, ' '),
    default => join(concat($content, $cmd_options), ' '),
  }
  case $ensure {
    'absent': {
      $label        = "delete-${entity}-${real_name}"
      $cmd          = "sacctmgr -i del ${entity} ${real_name}"
      $check_unless = undef
    }
    default: {
      $label        = "add-${entity}-${real_name}"
      $cmd          = "sacctmgr -i add ${entity} ${real_name} ${opts}"
      $check_unless = "test -n \"$(sacctmgr --noheader -p list ${entity} | grep ${real_name})\""
    }
  }
  if $slurm::service_manage {
    #notice($cmd)
    exec { $label:
      path    => '/sbin:/usr/bin:/usr/sbin:/bin',
      command => $cmd,
      unless  => $check_unless,
      require => Class['slurm::config'],
    }
  }
  else {
    warning("SKIPPING Application of ${module_name}{'${label}'} as slurm::service_manage == ${slurm::service_manage}")
  }
}
