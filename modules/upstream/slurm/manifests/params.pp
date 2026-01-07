################################################################################
# Time-stamp: <Thu 2022-06-30 14:37 svarrette>
#
# File::      <tt>params.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::params
#
# In this class are defined as default variables values that are used in all
# other slurm classes and definitions.
# This class should be included, where necessary, and eventually be enhanced
# with support for more Operating Systems.
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::params {
  #### MODULE INTERNAL VARIABLES  #########
  # (Modify to adapt to unsupported OSes)
  #########################################
  $pre_requisite_packages = $facts['os']['family'] ? {
    'Redhat' => [
      'hwloc', 'hwloc-devel', 'hwloc-plugins', 'numactl', 'numactl-devel',
      'http-parser-devel', 'json-c-devel',
      'lua', 'lua-devel',
      'mysql-devel',
      'openssl', 'openssl-devel',
      'pam-devel',
      'perl-devel', 'perl-CPAN',
      'readline', 'readline-devel',
      'libX11-devel',
      'libssh2-devel',
      'libevent-devel',
      'python3', 'python3-devel',
    ],
    default => []
  }

  # Probably out of scope here, but useful
  $extra_packages = $facts['os']['family'] ? {
    'Redhat' => [
      'infiniband-diags', 'rrdtool-devel',
    ],
    default  => []
  }

  # Which daemon to configure / install
  $with_slurmd    = false
  $with_slurmctld = false
  $with_slurmdbd  = false

  # Whether or not this module should configure firewall[d]
  $manage_firewall   = false
  # Whether or not this module should manage the accounting
  $manage_accounting = false

  # Configuration directory & file
  $configdir = $facts['os']['name'] ? {
    default => '/etc/slurm',
  }
  $logdir = $facts['os']['name'] ? {
    default => '/var/log/slurm'
  }
  # $piddir = $::operatingsystem ? {
  #   default => '/var/run/slurm',
  # }
  # Slurm controller save state directory
  $slurmctld_libdir = $facts['os']['name'] ? {
    default => '/var/lib/slurmctld',
  }

  $configdir_mode = '0755'

  # The below directory (absolute path) is used as a target for synchronizing the
  # Slurm configuration
  $shared_configdir = ''

  # Where the [git] control repository will be cloned
  $repo_basedir = '/usr/local/src/git'

  # $configdir_owner = $::operatingsystem ? {
  #   default => 'root',
  # }
  # $configdir_group = $::operatingsystem ? {
  #   default => 'root',
  # }

  ### Log directory
  # $logdir_mode = $::operatingsystem ? {
  #   default => '750',
  # }
  # $logdir_owner = $::operatingsystem ? {
  #   default => 'root',
  # }
  # $logdir_group = $::operatingsystem ? {
  #   default => 'adm',
  # }

  # PID for daemons
  # $piddir_mode = $::operatingsystem ? {
  #     default => '750',
  # }
  # $piddir_owner = $::operatingsystem ? {
  #     default => 'slurm',
  # }
  # $piddir_group = $::operatingsystem ? {
  #     default => 'adm',
  # }
  # $pidfile = $::operatingsystem ? {
  #     default => '/var/run/slurm/slurm.pid'
  # }

  ####################################################
  ### SLURM Configuration files (slurm.conf etc.)  ###
  ####################################################
  #
  # See https://slurm.schedmd.com/slurm.conf.html
  #
  $configfile              = 'slurm.conf'
  $configfile_mode         = '0644'

  # The name by which this Slurm managed cluster is known in the accounting database
  $clustername             = 'cluster'
  # Main / backup Slurm controllers
  $slurmctldhost           = $facts['networking']['hostname']
  $slurmctldaddr           = ''
  # OLD Deprecated
  $controlmachine          = $facts['networking']['hostname']
  $controladdr             = ''
  $backupcontroller        = ''
  $backupaddr              = ''

  # Accounting storage slurmdbd server
  $accountingstoragehost   = $facts['networking']['hostname']
  $accountingstorageexternalhost = []
  $accountingstoreflags = []
  # Authentication method for communications between Slurm components.
  $authtype                = 'munge' # in [ 'none', 'munge' ]
  $authinfo                = ''
  $authalttypes            = []
  $authaltparameters       = []
  $credtype                = 'munge'   # used to be Cryptotype

  # What level of association-based enforcement to impose on job submissions
  $accountingstorageenforce = ['qos', 'limits', 'associations']
  $accountingstoragetres    = ''
  $acctgatherenergytype     = 'none'
  $acctgatherfilesystemtype = 'none'
  $acctgatherinfinibandtype = 'none'
  $acctgatherprofiletype    = 'none'
  $batchstarttimeout       = 10
  $getenvtimeout           = 2
  $checkpointtype          = 'none'  # in ['none', 'ompi']
  $completewait            = 0
  $corespecplugin          = 'none'
  $cpufreqdef              = undef   # or in ['Conservative', 'OnDemand', 'Performance', 'PowerSave']
  $cpufreqgovernors        = ['OnDemand', 'Performance']  # in above + 'UserSpace'
  $debugflags              = []

  $defmempercpu            = 0           # 0 = unlimited, mutually exclusive with $defmempernode
  $dependencyparameters    = []          # in [ 'disable_remote_singleton', 'kill_invalid_depend' ]
  $maxmempercpu            = 0           # 0 = unlimited
  $maxmempernode           = undef
  $messagetimeout          = 10
  $defmempernode           = undef       # 0 = unlimited, mutually exclusive with $defmempercpu

  $disablerootjobs         = true
  $enforcepartlimits       = 'ALL'
  $epilog                  = ''
  $epilogslurmctld         = ''
  $grestypes               = []          # list of generic resources to be managed
  $healthcheckinterval     = 30
  $healthchecknodestate    = 'ANY'       # in ['ALLOC', 'ANY','CYCLE','IDLE','MIXED']
  $healthcheckprogram      = ''
  $inactivelimit           = 0           # 0 = unlimited
  $jobacctgathertype       = 'cgroup'    # in [ "linux", "cgroup", "none"]
  $jobacctgatherfrequency  = 30
  $jobacctgatherparams     = ''          # in [ 'NoShared', 'UsePss', 'NoOverMemoryKill']
  $jobcheckpointdir        = ''
  $jobcomphost             = ''          # machine hosting the job completion database
  $jobcomploc              = 'slurmjobs' # where job completion records are written (DB name, filename...)
  $jobcomptype             = 'none'      # in ["none", "elasticsearch", "filetxt", "mysql", "script"]
  $jobcontainertype        = 'none'      # In ['cncu', 'none'] (CNCU = Compute Node Clean Up on Cray)
  $jobrequeue              = true
  $jobsubmitplugins        = ['lua']   #
  $killwait                = 30          # sec. interval given to a job's processes between the SIGTERM and SIGKILL
  $launchparameters        = ''
  $launchtype              = 'slurm'
  $licenses                = ''          # Specification of licenses
  $maildomain              = $facts['networking']['domain']
  $mailprog                = '/bin/mail'
  $maxarraysize            = undef
  $maxjobcount             = undef
  $maxtaskspernode         = 512
  $metrics                 = 'openmetrics'
  # Default type of MPI to be used. Srun may override this configuration parameter in any case.
  # in ['lam','mpich1_p4','mpich1_shmem','mpichgm','mpichmx','mvapich','none','openmpi','pmi2']
  $mpidefault              = 'none'   # See https://slurm.schedmd.com/mpi_guide.html
  $mpiparams               = ''

  #
  # Nodes
  # Format
  # { 'nodename' => 'CPUs=xx Sockets=xx...' }
  # OR
  # { 'nodename' => {
  #     comment => 'a comment',
  #     content =>'CPUs=xx Sockets=xx...',
  # }
  # }
  $nodes                   = {}

  $preemptmode             = ['REQUEUE'] # in ['OFF','CANCEL','CHECKPOINT','GANG','REQUEUE','SUSPEND']
  $preempttype             = 'qos'         # in ['none', 'partition_prio', 'qos']
  $prioritydecayhalflife   = '5-0'         # aka 5 days
  $priorityfavorsmall      = false
  $priorityflags           = []            # in ['ACCRUE_ALWAYS','CALCULATE_RUNNING','DEPTH_OBLIVIOUS',
  #                                              'FAIR_TREE','INCR_ONLY','MAX_TRES',
  #                                              'SMALL_RELATIVE_TO_TIME']
  $prioritymaxage          = '7-0'
  $priorityweighttres      = ''
  $prioritytype            = 'multifactor' # in ['basic', 'multifactor']
  $priorityusageresetperiod = 'NONE'       # in ['NONE','NOW','DAILY','WEEKLY','MONTHLY','QUARTERLY','YEARLY']
  $priorityweightage       = 0
  $priorityweightfairshare = 0
  $priorityweightjobsize   = 0
  $priorityweightpartition = 0
  $priorityweightqos       = 0
  $privatedata             = []  # in ['accounts','cloud','jobs','nodes','partitions','reservations','usage','users']
  $proctracktype           = 'cgroup'      # in ['cgroup', 'cray', 'linuxproc', 'lua', 'sgi_job','pgid']

  $prolog                  = ''
  $prologflags             = []
  $prologslurmctld         = ''
  $propagateresourcelimits = []
  $propagateresourcelimits_except = ['MEMLOCK'] # see https://slurm.schedmd.com/faq.html#memlock
  $reconfigflags           = []
  $resvoverrun             = 0
  $rebootprogram           = '/sbin/reboot'
  $resumetimeout           = 60
  $resumeprogram           = ''
  $resumefailprogram       = ''
  $resumerate              = 300
  # Controls when a DOWN node will be returned to service
  $returntoservice         = 1  # in [0, 1, 2]
  $suspendprogram          = ''
  $suspendtimeout          = 0
  $suspendtime             = 0
  $suspendrate             = 0
  $suspendexcnodes         = ''
  $suspendexcparts         = ''
  $suspendexcstates        = []
  $statesavelocation       = '/var/lib/slurmctld'
  $schedulertype           = 'backfill' # in ['backfill', 'builtin', 'hold']
  $schedulerparameters     = []
  $selecttype              = 'cons_res' # in ['bluegene','cons_res','cray','linear','serial' ]
  $selecttype_params       = ['CR_Core_Memory', 'CR_CORE_DEFAULT_DIST_BLOCK']
  # Log details
  $slurmdbddebug           = 'info'
  $slurmdbddebugsyslog     = ''
  $slurmctlddebug          = 'info'
  $slurmctldsyslogdebug    = ''
  $slurmddebug             = 'info'
  $slurmdsyslogdebug       = ''
  # Ports
  $slurmctldport           = 6817
  $slurmdport              = 6818
  $slurmdbdport            = 6819
  # Timeout
  $slurmctldtimeout        = 120
  $slurmdtimeout           = 300
  $slurmctldparameters     = []
  $slurmdparameters        = []
  $slurmdspooldir          = ''
  $srunportrange           = '50000-53000'
  $srunepilog              = ''
  $srunprolog              = ''
  $switchtype              = 'none' # in ['nrt', 'none']
  $taskepilog              = ''
  $taskplugin              = ['affinity','cgroup'] # in ['affinity', 'cgroup','none']
  $taskpluginparams        = []
  $taskprolog              = ''
  $tmpfs                   = '/tmp'
  $tresbillingweights      = ''
  $waittime                = 0
  $unkillablesteptimeout   = 60
  $x11parameters           = ''

  ######
  ###### Hierarchical Network Topology description -- topology.conf
  ######
  # Which topology plugin to be used for determining the network topology and
  # optimizing job allocations to minimize network contention
  # Elligible values
  #   3d_torus  -- best-fit logic over three-dimensional topology
  #   node_rank -- orders nodes based upon information a node_rank field in the
  #       node record as generated by a select plugin. Slurm performs a best-fit
  #       algorithm over those ordered nodes
  #   none -- default for other systems, best-fit logic over one-dimensional topology
  #   tree -- used for a hierarchical network as described in a topology.conf file
  $topology_configfile = 'topology.conf'
  $topology = none
  # Format
  # 'switchname' => {
  #              [comment => 'This will become a comment above the line',]
  #              nodes => '<nodes>',
  #              [linkspeed => '<speed>',]
  #        }
  $topology_tree = {}

  ##################################
  ### Partition / QOS definition ###
  ##################################
  # Default Partition / QoS. Format:
  # '<name>' => {
  #     nodes         => n,           # Number of nodes
  #     default       => true|false,  # Default partition?
  #     hidden        => true|false,  # Hidden partition?
  #     allowgroups   => 'ALL|group[,group]*'
  #     allowaccounts => 'ALL|acct[,acct]*'
  #     allowqos      => 'ALL|qos[,qos]*'
  #     state         => 'UP|DOWN|DRAIN|INACTIVE'
  #     oversubscribe => 'EXCLUSIVE|FORCE|YES|NO' (replace :shared)
  #     #=== Time: Format is minutes, minutes:seconds, hours:minutes:seconds, days-hours,
  #             days-hours:minutes, days-hours:minutes:seconds or "UNLIMITED"
  #     default_time  => 'UNLIMITED|DD-HH:MM:SS',
  #     max_time      => 'UNLIMITED|DD-HH:MM:SS',
  #     #=== associated QoS config, named 'qos-<partition>' ===
  #     priority      => n           # QoS priority (default: 0)
  #     preempt       => 'qos-<name>
  # }
  $partitions = {}
  $qos        = {}

  ###
  ### Cgroup support -- cgroup.conf
  ###
  # $cgroup_releaseagentdir = $::operatingsystem ? {
  #   default => '/etc/slurm/cgroup'
  # }
  $cgroup_configfile = 'cgroup.conf'
  $cgroup_automount  = true
  $cgroup_mountpoint = $::facts.dig('os', 'release', 'major') ? {
    '6'     => '/cgroup',
    default => '/sys/fs/cgroup',
  }
  ### task/cgroup plugin ###
  $cgroup_alloweddevices            = []    # if non-empty, cgroup_allowed_devices_file.conf
  # will host the list of devices that need to be allowed by default for all the jobs
  $cgroup_alloweddevices_configfile = 'cgroup_allowed_devices_file.conf'
  $cgroup_allowedkmemspace          = undef   # amount of the allocated kernel memory
  $cgroup_allowedramspace           = 100     # percentage of the allocated memory
  $cgroup_allowedswapspace          = 0       # percentage of the swap space
  $cgroup_constraincores            = true
  $cgroup_constraindevices          = false   #  constrain the job's allowed devices based on GRES allocated resources.
  $cgroup_constrainkmemspace        = true
  $cgroup_constrainramspace         = true
  $cgroup_constrainswapspace        = true
  $cgroup_maxrampercent             = 100   # upper bound in percent of total RAM on the RAM constraint for a job.
  $cgroup_maxswappercent            = 100   # upper bound (in percent of total RAM) on the amount of RAM+Swap
  $cgroup_maxkmempercent            = 100   # upper bound in percent of total Kmem for a job.
  $cgroup_minkmemspace              = 30    # lower bound (in MB) on the memory limits defined by AllowedKmemSpace.
  $cgroup_minramspace               = 30    # lower bound (in MB) on the memory limits defined by AllowedRAMSpace & AllowedSwapSpace.
  $cgroup_taskaffinity              = false # if true, this feature requires the Portable Hardware Locality (hwloc) library
  $cgroup_signalchildrenprocesses   = false # if true, send signals (for cancelling, suspending, resuming, etc.) to all children processes in a job/step.

  ###
  ### Generic RESource management -- gres.conf
  ###
  $gres_configfile    = 'gres.conf'

  #
  # SPANK - Slurm Plug-in Architecture for Node and job (K)control
  # See <https://slurm.schedmd.com/spank.html>
  #
  $plugstack_configfile = 'plugstack.conf'
  $pluginsdir           = 'plugstack.conf.d'
  $pluginsdir_target    = undef

  #####################
  ### SLURM Daemons ###
  #####################
  # ensure the presence (or absence) of slurm
  $ensure = 'present'

  # Make sure the clocks, users and groups (UIDs and GIDs) are synchronized
  # across the cluster.
  # Slurm user / group identifiers
  $username = 'slurm'
  $uid      = 991
  $group    = $username
  $gid      = $uid
  $home     = "/var/lib/${username}"
  $comment  = 'SLURM workload manager'
  $shell    = '/bin/bash'

  # Slurmd associated services
  $servicename = $facts['os']['name'] ? {
    default => 'slurmd'
  }
  $controller_servicename = $facts['os']['name'] ? {
    default => 'slurmctld'
  }
  $dbd_servicename = $facts['os']['name'] ? {
    default => 'slurmdbd'
  }
  # used for pattern in a service ressource
  $processname            = $servicename
  $controller_processname = $controller_servicename
  $dbd_processname        = $dbd_servicename

  $hasstatus = $facts['os']['name'] ? {
    /(?i-mx:ubuntu|debian)/        => false,
    /(?i-mx:centos|fedora|redhat)/ => true,
    default => true,
  }
  $hasrestart = $facts['os']['name'] ? {
    default => true,
  }
  # Whether to manage the slurm services
  $service_manage = true

  ##########################################
  ### SLURM Sources and Building Process ###
  ##########################################
  # Which group install is required to build the Slurm sources -- see slurm::build[::redhat]
  # Makes only sense on yum-based systems
  $groupinstall = $facts['os']['family'] ? {
    'Redhat' => 'Development tools',
    default  => undef
  }
  # Which version of Slurm to grab and build
  $version = '20.11.3'

  ### SLURM Sources
  # Checksum for the slurm source archive (empty means no check will be done)
  $src_checksum      = 'dcf328865591b42b6c8f5586b3e396e6eb30dcd7'
  $src_checksum_type = 'sha1'
  # From where the Slurm sources can be downloaded
  $download_baseurl    = 'https://download.schedmd.com/slurm/'

  $do_build            = true
  $do_package_install  = true
  # Where to place the sources
  $srcdir = $facts['os']['name'] ? {
    default => '/usr/local/src'
  }
  ### Slurm Build
  # Where to place the builds of the sources (i.e. RPMs, debs...)
  $builddir = $facts['os']['family'] ? {
    'Redhat' => '/root/rpmbuild', # rpmbuild _topdir Build directory
    default  => '/tmp/slurmbuild',
  }
  # Build options -- see https://github.com/SchedMD/slurm/blob/master/slurm.spec
  $build_with = [
    #'cray',         # build for a Native-Slurm Cray system
    #'cray_network', # build for a non-Cray system with a Cray network
    #'cray_shasta',  # build for a Cray Shasta system
    'hdf5',          # require hdf5 support
    'hwloc',         # require hwloc support
    'lua',           # build Slurm LUA bindings
    'mysql',         # require mysql/mariadb support
    'numa',          # require NUMA support
    'slurmrestd',    # build slurmrestd
    #'slurmsmwd',    # build slurmsmwd
    #'ucx',          # require ucx support
    'pmix',         # require pmix support
  ]
  $build_without = [
    #'debug',        # don't compile with debugging symbols
    #'munge',        # DEPRECATED - don't build auth-munge RPM
    #'pam',          # don't require pam-devel RPM to be installed
    #'x11',          # disable internal X11 support
  ]
  # Generated RPMs basenames, without versions and os specific suffixes.
  # Exact filename will be on the form
  #    <basename>-<version>-<n>.el7.centos.x86_64.rpm
  #$rpm_basename = 'slurm'
  $common_rpms_basename = [
    'slurm',           # Main RPM basename covering slurmd and slurmctld
    'slurm-contribs',  # Perl tool to print Slurm job state information
    'slurm-devel',     # Development package for Slurm
    # 'slurm-example-configs', # Example config files for Slurm (/etc/slurm/*.example)
    'slurm-libpmi',    # Slurm libpmi[2].so - PMI-1 and PMI-2 compatibility libraries
    #                    You probably want to ensure 'pmix' is also installed
    #                    Beware that PMIx also feature PMI-1 and PMI-2
    #                    compatibility libraries  that unfortunately conflicts
    #                    with these ones
    'slurm-pam_slurm', # PAM module for restricting access to compute nodes via Slurm
    'slurm-perlapi',   # Perl API to Slurm
  ]
  $slurmdbd_rpms_basename = [
    'slurm-slurmdbd',  # Slurm database daemon
    #  'slurm-sql',       # Slurm SQL support
  ]
  $slurmctld_rpms_basename = [
    'slurm-slurmctld',  # Slurm controller daemon - only on the head node
  ]
  $slurmd_rpms_basename = [
    'slurm-slurmd',     # Slurm daemon - only on the compute nodes
  ]
  $extra_rpms_basename = [
    'slurm-openlava',  # openlava/LSF wrappers for transitition from OpenLava/LSF to Slurm
    'slurm-torque',    # Torque/PBS wrappers for transitition from Torque/PBS to Slurm
  ]
  $wrappers = []

  ############################
  ### PMI Exascale (PMIx)  ###
  ############################
  # See https://pmix.org/code/getting-the-reference-implementation/
  $with_pmix              = false # Whether or not using PMIx
  $pmix_version           = '3.2.3'
  # Checksum for the pmix source archive (empty means no check will be done)
  $pmix_src_checksum      = '97978abcd4da1b2a3d2bf2452247c4d47f8cc6a3'
  $pmix_src_checksum_type = 'sha1'
  # From where the Slurm sources can be downloaded
  $pmix_download_baseurl  = 'https://github.com/openpmix/openpmix/releases/download'
  $pmix_rpms = [
    'pmix',           # Main RPM basename
    'pmix-devel',     # New mandatory development RPMS (required for detecting PMIx for Slurm)
    'pmix-libpmi',    # PMI-1 and PMI-2 compatibility libraries (i.e. libpmi and
    #                   libpmi2 libraries)  - conflicts with slurm-libpmi so
    #                   SHOULD NOT be installed
  ]
  $pmix_install_path = '/usr'   # if install in opt (for instance with
  #                    slurm::pmix::build::defines set to [ 'install_in_opt 1' ],
  #                    you will need to set this path to /opt/pmix/${pmix_version}
  #                    -- NOT YET IMPLEMENTED

  ####################################
  ### MUNGE authentication service ###
  ####################################
  # see https://github.com/dun/munge
  # We assume it will be used for shared key authentication, and the shared key
  # can be provided to puppet via a URI.
  $manage_munge     = true   # Whether or not this module should manage munge
  # Munge user/group identifiers, and attributes for the munge user
  $munge_username   = 'munge'
  $munge_uid        = 992
  $munge_group      = $munge_username
  $munge_gid        = $munge_uid
  $munge_home       = "/var/lib/${munge_username}"
  $munge_comment    = "MUNGE Uid 'N' Gid Emporium"
  $munge_shell      = '/sbin/nologin'
  # Should the key be created if absent ?
  $munge_create_key = true #false
  $munge_key        = '/etc/munge/munge.key'
  # Set the content of the DAEMON_ARGS variable
  $munge_daemon_args = []
  # Packages to install
  $munge_package = $facts['os']['name'] ? {
    default => 'munge'
  }
  $munge_extra_packages = $facts['os']['name'] ? {
    /(?i-mx:ubuntu|debian)/        => ['libmunge-dev'],
    /(?i-mx:centos|fedora|redhat|rocky)/ => ['munge-devel', 'munge-libs'],
    default => [],
  }

  $munge_configdir = $facts['os']['name'] ? {
    default => '/etc/munge',
  }
  $munge_logdir = $facts['os']['name'] ? {
    default => '/var/log/munge',
  }
  $munge_piddir = $facts['os']['name'] ? {
    default => '/var/run/munge',
  }
  $munge_default_sysconfig = $facts['os']['name'] ? {
    /(?i-mx:ubuntu|debian)/ => '/etc/default/munge',
    default                 => '/etc/sysconfig/munge'
  }
  $munge_servicename = $facts['os']['name'] ? {
    default => 'munge'
  }
  $munge_processname = $facts['os']['name'] ? {
    default => 'munge'
  }

  ##############################################
  ### Pluggable Authentication Modules (PAM) ###
  ##############################################
  $manage_pam          = true   # Whether or not this module should manage pam
  $use_pam             = true
  $pam_allowed_users   = []
  $pam_servicename     = 'slurm'
  $pam_configfile      = '/etc/pam.d/slurm'
  # Default content of /etc/pam.d/slurm
  $pam_content         = template('slurm/pam_slurm.erb')
  # Default ulimit -- update at least PAM MEMLOCK limits (required for MPI) +
  # nproc (max number of processes)
  $ulimits             = {
    'memlock' => 'unlimited',
    'stack'   => 'unlimited',
    'nproc'   => '10240',
  }

  # Source file for /etc/security/limits.d/slurm.conf
  $pam_limits_source   = 'puppet:///modules/slurm/limits.memlock'
  # Whether or not use the pam_slurm_adopt  module (to Adopt incoming
  # connections into jobs) -- see
  # https://github.com/SchedMD/slurm/tree/master/contribs/pam_slurm_adopt
  $use_pam_slurm_adopt = false

  ######################
  ### SLURM Plugins  ###
  ######################
  $job_submit_lua = 'job_submit.lua'

  #####################################################
  ### SLURM DataBase Configuration (slurmdbd.conf)  ###
  #####################################################
  $dbd_configfile      = 'slurmdbd.conf'
  $dbd_configfile_mode = '0600'
  $archivedir          = '/tmp'
  $archiveevents       = false # When purging events also archive them?
  $archivejobs         = false # When purging jobs also archive them?
  $archiveresvs        = false # When purging reservations also archive them?
  $archivesteps        = false # When purging steps also archive them?
  $archivesuspend      = false # When purging suspend data also archive it?
  $archivetxn          = false # When purging transaction data also archive it?
  $archiveusage        = false # When purging usage data (Cluster, Association and WCKey) also archive it.
  $commitdelay         = 0 # How many seconds between commits on a connection from a Slurmctld
  $dbdhost             = 'localhost'
  $dbdaddr             = 'localhost'
  $dbdbackuphost       = ''
  $storagehost         = $facts['networking']['hostname']
  $storagebackuphost   = ''
  $storageloc          = 'slurm'    # name of the DB as the location where accounting records are written
  $storageport         = 3306
  $storagetype         = 'mysql'    # accounting storage mechanism type: accounting_storage/<storagetype>
  $storageuser         = $username
  $storagepass         = 'janIR4TvYoSEqNF94QM' # use 'openssl rand 14 -base64' for instance
  $trackslurmctlddown  = false
  $bootstrap_mysql     = true

  ##############################
  ### MariaDB configuration  ###
  ##############################
  # Buffer Pool Size: 256MB + 256 * log2(RAM size in GB)
  $innodb_buffer_pool_size  = '256M'
  $innodb_log_file_size     = '24M'
  $innodb_lock_wait_timeout = 500
}
