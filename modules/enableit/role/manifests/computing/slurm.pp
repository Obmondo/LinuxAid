# SLURM
class role::computing::slurm (
  Optional[String]               $munge_key               = undef,
  Boolean                        $__blendable,
  Boolean                        $enable                  = false,
  Eit_types::SimpleString        $interface               = undef,
  Array[Eit_types::IPCIDR]       $node_cidrs              = [],
  Eit_types::Version             $slurm_version           = '18.08.7',
  Eit_types::Version             $munge_version           = '0.5.11',
  Boolean                        $slurmctld               = false,
  Boolean                        $slurmdbd                = false,
  Boolean                        $slurmd                  = true,
  Hash                           $nodes                   = {},
  Hash                           $partitions              = {},
  String                         $srun_port_range         = '50000-53000',
  Stdlib::Host                   $accounting_storage_host = $::facts['hostname'],
  Stdlib::Host                   $control_machine         = $::facts['hostname'],
  # Make DOWN nodes available automatically, even after unexpected reboots. This
  # might not be a good idea, but let's try it for now. The alternative is that
  # we manually have to bring up DOWN nodes.
  Integer[0,2]                   $return_to_service       = 2,
  Boolean                        $disable_root_jobs       = false,
  Boolean                        $use_pam                 = false,
  Boolean                        $hwloc_enabled           = false,
) inherits ::role::computing {

  contain 'profile::computing::slurm'
}
