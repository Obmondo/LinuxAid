
# @summary Class for managing the Slurm computing role
#
# @param munge_key The munge key for authentication. Defaults to undef.
#
# @param $__blendable
# Indicates if the role is blendable.
#
# @param enable Whether to enable Slurm. Defaults to false.
#
# @param interface The network interface to use. Defaults to undef.
#
# @param node_cidrs The CIDR ranges for the nodes. Defaults to an empty array.
#
# @param slurm_version The version of Slurm to install. Defaults to '18.08.7'.
#
# @param munge_version The version of Munge to install. Defaults to '0.5.11'.
#
# @param slurmctld Whether to enable the Slurm control daemon. Defaults to false.
#
# @param slurmdbd Whether to enable the Slurm database daemon. Defaults to false.
#
# @param slurmd Whether to enable the Slurm daemon. Defaults to true.
#
# @param nodes A hash of nodes' configuration. Defaults to an empty hash.
#
# @param partitions A hash of partitions' configuration. Defaults to an empty hash.
#
# @param srun_port_range The port range for srun. Defaults to '50000-53000'.
#
# @param accounting_storage_host The host for accounting storage. Defaults to the hostname from facts.
#
# @param control_machine The control machine for Slurm. Defaults to the hostname from facts.
#
# @param return_to_service The number of attempts to return downed nodes to service. Defaults to 2.
#
# @param disable_root_jobs Whether to disable root jobs. Defaults to false.
#
# @param use_pam Whether to use PAM for authentication. Defaults to false.
#
# @param hwloc_enabled Whether to enable hwloc support. Defaults to false.
#
# @param __encrypt The list of params, which needs to be encrypted
#
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
  Stdlib::Host                   $accounting_storage_host = $facts['networking']['hostname'],
  Stdlib::Host                   $control_machine         = $facts['networking']['hostname'],
  Integer[0,2]                   $return_to_service       = 2,
  Boolean                        $disable_root_jobs       = false,
  Boolean                        $use_pam                 = false,
  Boolean                        $hwloc_enabled           = false,

  Eit_types::Encrypt::Params     $__encrypt               = [
    'munge_key',
  ]

) inherits ::role::computing {
  contain 'profile::computing::slurm'
}
