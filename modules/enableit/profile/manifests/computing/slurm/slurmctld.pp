# Slurm slurm::slurmctld
class profile::computing::slurm::slurmctld (
  Eit_types::SimpleString $interface,
  Array[Eit_types::IPCIDR] $node_cidrs,
) {

  firewall_multi {'100 allow slurmctld':
    jump    => 'accept',
    iniface => $interface,
    source  => $node_cidrs,
    dport   => 6817,
    proto   => 'tcp',
  }

  include ::slurm::slurmctld
  include common::monitor::exporter::slurm
  include monitor::system::slurm
}
