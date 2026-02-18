
# @summary Class for managing the Slurm computing role
#
# @param munge_key The munge key for authentication. Defaults to undef.
#
# @param __blendable Indicates if the role is blendable.
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
# @param encrypt_params The list of params, which needs to be encrypted
#
# @param noop_value The noop value.
#
# @param jwt_key Secret key for signing JSON Web Tokens securely.
#
# @param slurm_web Web interface for managing SLURM cluster operations.
#
# @param slurm_agent Agent responsible for executing SLURM job tasks efficiently.
#
# @param slurm_gateway Gateway facilitating client access to the SLURM system.
#
# @param slurm_policy Rules governing resource allocation in SLURM clusters.
#
# @param db_buffer_pool_size Size of memory pool for database caching operations.
#
# @param slurmctldport Port for slurm slurmctld.
#
# @param metrics Optional metrics array.
#
# @param db_log_file_size Maximum size allocated for database log files.
#
# @param all_users_limit_nofile Optional PAM `nofile` value for all users.
#
# @param slurmd_limit_nofile Optional systemd `LimitNOFILE` value for slurmd service.
#
# @groups authentication munge_key, jwt_key, encrypt_params
#
# @groups daemon_control slurmctld, slurmdbd, slurmd
#
# @groups network interface, node_cidrs, accounting_storage_host, control_machine, metrics
#
# @groups version_control slurm_version, munge_version
#
# @groups configuration nodes, partitions, srun_port_range, disable_root_jobs, return_to_service, use_pam, hwloc_enabled
#
# @groups management enable, noop_value
#
# @groups slurm slurm_web, slurm_agent, slurm_gateway, slurm_policy, slurmctldport
#
# @groups db db_buffer_pool_size, db_log_file_size
#
# @groups limits all_users_limit_nofile, slurmd_limit_nofile
#
# @encrypt_params munge_key, jwt_key, slurm_gateway.*.bind_password
#
class role::computing::slurm (
  Boolean                             $__blendable,
  Optional[Variant[
    Eit_Files::Source,
    String
  ]]                                  $munge_key               = undef,
  Optional[Eit_Files::Source]         $jwt_key                 = undef,
  Boolean                             $enable                  = false,
  Boolean                             $noop_value              = true,
  Eit_types::SimpleString             $interface               = undef,
  Array[Eit_types::IPCIDR]            $node_cidrs              = [],
  Eit_types::Version                  $slurm_version           = '18.08.7',
  Eit_types::Version                  $munge_version           = '0.5.11',
  Boolean                             $slurmctld               = false,
  Boolean                             $slurmdbd                = false,
  Boolean                             $slurmd                  = true,
  Hash                                $nodes                   = {},
  Hash                                $partitions              = {},
  String                              $srun_port_range         = '50000-53000',
  Stdlib::Port                        $slurmctldport           = 6817,
  Eit_types::Slurm::Metrics           $metrics                 = [],
  Stdlib::Host                        $accounting_storage_host = $facts['networking']['hostname'],
  Stdlib::Host                        $control_machine         = $facts['networking']['hostname'],
  Integer[0,2]                        $return_to_service       = 2,
  Boolean                             $disable_root_jobs       = false,
  Boolean                             $use_pam                 = false,
  Boolean                             $hwloc_enabled           = false,
  Boolean                             $slurm_web               = false,
  Optional[Eit_types::Slurm::Agent]   $slurm_agent             = undef,
  Optional[Eit_types::Slurm::Gateway] $slurm_gateway           = undef,
  Optional[Eit_types::Slurm::Policy]  $slurm_policy            = undef,
  String                              $db_buffer_pool_size     = '256M',
  String                              $db_log_file_size        = '24M',
  Optional[Integer[1]]                $all_users_limit_nofile  = undef,
  Optional[Integer[1]]                $slurmd_limit_nofile     = undef,
  Eit_types::Encrypt::Params          $encrypt_params          = ['munge_key', 'jwt_key','slurm_gateway.*.bind_password']

) inherits ::role::computing {
  contain 'profile::computing::slurm'

  if $slurm_web {
    contain profile::computing::slurm::slurm_web
    contain role::web::haproxy
  }
}
