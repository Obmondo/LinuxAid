################################################################################
# Time-stamp: <Thu 2022-06-30 14:03 svarrette>
#
# File::      <tt>munge.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::accounting
#
# Setup the accounting structure
#
#@param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of the Munge service
#
class slurm::accounting(
  String  $ensure = $slurm::params::ensure,
  $cluster        = undef,
  $qos            = undef,
  $account        = undef,
)
inherits slurm::params
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  ### Clusters
  $clusters = $cluster ? {
    undef   => $slurm::clustername,
    default => $cluster
  }
  if $clusters.is_a(String) or $clusters.is_a(Array) {
    slurm::acct::cluster{ $clusters:
      ensure => $ensure,
    }
  }
  elsif $clusters.is_a(Hash) {
    $clusters.each |$k, $v| {
      slurm::acct::cluster{ $k:
        ensure  => $ensure,
        options => $v,
      }
    }
  }

  ### QOS
  # Make the default qos out of the partitions definitions
  $slurm::partitions.each |$partition, $h| {
    if $partition != 'DEFAULT' {
      $qosname = "qos-${partition}"
      slurm::acct::qos{ $qosname:
        ensure   => $ensure,
        priority => ($h['priority'] + 0),
      }
      # Eventually complete it with entries from the $slurm::qos hash
      unless empty($qos) {
        if $slurm::qos[$qosname] {
          Slurm::Acct::Qos[$qosname] {
            options => $slurm::qos[$qosname],
          }
        }
      }
    }
  }
  $qoses = $qos ? {
    undef   => $slurm::qos,
    default => $qos,
  }
  # Complete with the explicit qos hash
  $qoses.each |$qosname, $h| {
    unless $slurm::partitions[regsubst($qosname, '^qos-', '')] {
      slurm::acct::qos{ $qosname:
        ensure  => $ensure,
      }
      if $h.is_a(String) {
        Slurm::Acct::Qos[$qosname] {
          content => $h,
        }
      }
      else {
        Slurm::Acct::Qos[$qosname] {
          options => $h,
        }
      }
    }
  }
  # if $qos != undef {
    #   if $qos.is_a(String) or $qos.is_a(Array) {
      #     slurm::acct::qos{ $qos:
        #       ensure => $ensure,
        #     }
      #   }
    #   elsif $qos.is_a(Hash) {
      #     $qos.each |$k, $v| {
        #       slurm::acct::qos{ $k:
          #         ensure => $ensure,
          #       }
        #       unless $v == undef {
          #         Slurm::Acct::Qos[$k] {
            #           options => $v,
            #         }
          #       }
        #     }
      #   }
    # }
}
