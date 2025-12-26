# SLURM Setup
# slurm installation is done by package,
# which is build by enableit and its in our custom repo
# To generate munge key:
# "dd if=/dev/urandom bs=1 count=1024 > ${key_filename}",
# OR "create-munge-key",
#
class profile::computing::slurm (
  Boolean                        $enable                  = $::role::computing::slurm::enable,
  Boolean                        $noop_value              = true,
  Eit_types::SimpleString        $interface               = $::role::computing::slurm::interface,
  Array[Eit_types::IPCIDR]       $node_cidrs              = $::role::computing::slurm::node_cidrs,
  Eit_types::Version             $slurm_version           = $::role::computing::slurm::slurm_version,
  Eit_types::Version             $munge_version           = $::role::computing::slurm::munge_version,
  Optional[Variant[
    Eit_Files::Source,
    String
  ]]                             $munge_key               = $::role::computing::slurm::munge_key,
  Optional[Eit_Files::Source]    $jwt_key                 = $::role::computing::slurm::jwt_key,
  Boolean                        $slurmctld               = $::role::computing::slurm::slurmctld,
  Boolean                        $slurmdbd                = $::role::computing::slurm::slurmdbd,
  Boolean                        $slurmd                  = $::role::computing::slurm::slurmd,
  Hash                           $nodes                   = $::role::computing::slurm::nodes,
  Hash                           $partitions              = $::role::computing::slurm::partitions,
  String                         $srun_port_range         = $::role::computing::slurm::srun_port_range,
  Stdlib::Host                   $accounting_storage_host = $::role::computing::slurm::accounting_storage_host,
  Stdlib::Host                   $control_machine         = $::role::computing::slurm::control_machine,
  # Make DOWN nodes available automatically, even after unexpected reboots. This
  # might not be a good idea, but let's try it for now. The alternative is that
  # we manually have to bring up DOWN nodes.
  Integer[0,2]                   $return_to_service       = $::role::computing::slurm::return_to_service,
  Boolean                        $disable_root_jobs       = $::role::computing::slurm::disable_root_jobs,
  Boolean                        $use_pam                 = $::role::computing::slurm::use_pam,
  Boolean                        $hwloc_enabled           = $::role::computing::slurm::hwloc_enabled,
  String                         $db_buffer_pool_size     = $::role::computing::slurm::db_buffer_pool_size,
  String                         $db_log_file_size        = $::role::computing::slurm::db_log_file_size,
) inherits ::profile::computing {

  # We manually install SLURM and munge packages because we're using packages
  # that we've compiled ourselves. This gets a bit ugly, but it mostly works...
  #
  # NOTE: There's an issue with uninstalling due to the upstream SLURM module
  # being weird.
  if $enable {
    package::install('slurm', {
      ensure => if $enable {
        $slurm_version
      },
    })
  }

  # Don't encrypt if file is supplied
  $_munge_key = type($munge_key) ? {
    String  => { munge_key_content => $munge_key.node_encrypt::secret },
    default => { munge_key_source => eit_files::to_file($munge_key)['resource']['source'] },
  }

  # Determine whether jwt_key should be managed
  $_jwt_key = $jwt_key ? {
    undef   => false,
    default => true,
  }

  if versioncmp($slurm_version, '24.0.11') >= 0 {
    $selecttype_value = 'cons_tres'
  } else {
    $selecttype_value = 'cons_res'
  }

  class { '::slurm':
    ensure                    => ensure_present($enable),
    version                   => $slurm_version,
    # managed by individual ::profile classes
    with_slurmd               => false,
    with_slurmctld            => false,
    with_slurmdbd             => false,
    service_manage            => true,
    authtype                  => 'munge',

    uid                       => 64030,
    gid                       => 64030,

    # Firewall
    manage_firewall           => false,
    # Install/Build
    do_build                  => false,
    do_package_install        => false,
    # PAM
    manage_pam                => $use_pam,
    use_pam                   => $use_pam,
    # Nodes
    nodes                     => $nodes,
    partitions                => $partitions,
    # Accounting
    manage_accounting         => true,
    accountingstoragehost     => $accounting_storage_host,
    # Control
    slurmctldhost             => $control_machine,
    selecttype                => $selecttype_value,
    # Munge
    manage_munge              => true,
    munge_create_key          => false,
    munge_uid                 => 64031,
    munge_gid                 => 64031,

    #JWT
    authalttypes              => if $_jwt_key {[ 'auth/jwt' ]},
    authaltparameters         => if $_jwt_key {[ 'jwt_key=/var/spool/slurm/jwt_hs256.key' ]},

    # Disable the Lua job submit plugin; broken/unnecessary
    jobsubmitplugins          => [],
    returntoservice           => $return_to_service,
    accountingstorageenforce  => [],
    disablerootjobs           => $disable_root_jobs,
    cgroup_taskaffinity       => $hwloc_enabled,
    cgroup_constrainkmemspace => false,
    cgroup_constrainramspace  => false,
    cgroup_constrainswapspace => false,

    *                         => $_munge_key,
  }

  if $enable and $slurmctld {
    package::install ('slurm-slurmctld', {
      ensure => $slurm_version,
    })

    class { '::profile::computing::slurm::slurmctld':
      interface  => $interface ,
      node_cidrs => $node_cidrs,
    }
  }

  if $enable and $slurmdbd {
    package::install ('slurm-slurmdbd', {
      ensure => $slurm_version,
    })

    class { '::profile::computing::slurm::slurmdbd':
      interface           => $interface,
      node_cidrs          => $node_cidrs,
      db_buffer_pool_size => '256M',
      db_log_file_size    => '24M',
    }
  }

  if $enable and $slurmd {
    package::install ('slurm-slurmd', {
      ensure => $slurm_version,
    })

    class { '::profile::computing::slurm::slurmd':
      interface  => $interface,
      node_cidrs => $node_cidrs,
    }
  }

  package { ['libjwt', 'libjwt-devel']:
    ensure => ensure_present($_jwt_key),
    noop   => $noop_value,
  }

  file { '/var/spool/slurm/jwt_hs256.key':
    ensure  => ensure_file($_jwt_key),
    source  => eit_files::to_file($jwt_key)['source'],
    noop    => $noop_value,
    require => Package['libjwt', 'libjwt-devel'],
  }

  if !$enable {
    package::remove( ['slurm', 'slurm-slurmdbd', 'slurm-slurmctld', 'slurm-slurmd', 'munge'])
  }
}
