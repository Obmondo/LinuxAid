# Slurm slurm::slurmd
class profile::computing::slurm::slurmd (
  Eit_types::SimpleString  $interface,
  Array[Eit_types::IPCIDR] $node_cidrs,
  String            $srun_port_range = '50000-53000',
) {


  firewall_multi {
    default:
      jump    => 'accept',
      iniface => $interface,
      source  => $node_cidrs,
      proto   => 'tcp',
      ;

    '100 allow slurmd':
      dport => 6818,
      ;

    '100 allow srun':
      dport => $srun_port_range,
      ;
  }

  include ::slurm::slurmd
}
