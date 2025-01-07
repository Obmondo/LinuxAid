#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/advanced.pp
#
node default {
  include slurm::params

  $clustername = 'thor'
  # Example of the topology tree
  $tree = {
    's0' => { nodes => 'dev[0-5]' },
    's1' => { nodes => 'dev-[6-11]' },
    's2' => { nodes => 'dev-[12-17]' },
    's3' => {
      comment   => 'GUID: XXXXXX - switch 0',
      switches  => 's[0-2]',
    linkspeed => '100Mb/s', },
  }
  # Definition of the nodes
  $nodes = {
    'DEFAULT' => {
      comment => 'Test',
    content => 'CPUs=1 Sockets=1 CoresPerSocket=1 ThreadsPerCore=1 RealMemory=512 State=UP', },
    'access'     => 'CPUs=2 Sockets=1 CoresPerSocket=2 ThreadsPerCore=1 State=UNKNOWN',
    'thor-[1-3]' => 'CPUs=2 Sockets=1 CoresPerSocket=2 ThreadsPerCore=1  RealMemory=400 State=UNKNOWN',
  }
  # Definition of the partitions
  $partitions = {
    'DEFAULT' => 'State=UP AllowGroups=clusterusers AllowAccounts=ALL DisableRootJobs=YES OverSubscribe=NO',
    'interactive' => {
      priority => 50,
      nodes    => 'iris-[081-090]',
    },
    'admin' => {
      priority => 100,
      hidden => true,
      nodes => 'iris-[001-100]',
      allowaccounts => 'ulhpc',
      allowgroups => 'project_sysadmins',
      allowqos => 'qos-admin',
      content => 'DefaultTime=0-10:00:00 MaxTime=5-00:00:00 MaxNodes=UNLIMITED',
    },
    'batch' => {
      priority => 50,
      nodes => 'iris-[001-080]',
      allowqos => ['qos-besteffort', 'qos-batch', 'qos-batch-001'],
      content => 'DefaultTime=0-10:00:00 MaxTime=5-00:00:00 MaxNodes=UNLIMITED',
    },
  }
  $qos = {
    'qos-besteffort' => { priority => 0, },
    'qos-batch' => {
      priority => 100,
      preempt  => 'qos-besteffort',
      grpnodes => 30,
    },
    'qos-interactive' => {
      preempt  => 'qos-besteffort',
      grpnodes => 8,
    },
    'qos-long' => {
      preempt  => 'qos-besteffort',
      grpnodes => 8,
    },
    'qos-batch-001' => 'Priority=100 Preempt=qos-besteffort GrpNodes=50 flags=OverPartQOS',
  }

  # Let's go, all-in-one run
  class { 'slurm':
    clustername     => $clustername,
    with_slurmdbd   => true,
    with_slurmctld  => true,
    with_slurmd     => true,
    manage_firewall => true,
    # topology      => 'tree',
    # topology_tree => $tree,
    # nodes         => $nodes,
    partitions      => $partitions,
    qos             => $qos,
    service_manage  => false,
  }

  #notice(inline_template("<%= scope['slurm::qos'].to_yaml %>"))
  include slurm::accounting
}
