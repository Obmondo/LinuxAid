# Slurm slurm::slurmd
class profile::computing::slurm::slurmd (
  Eit_types::SimpleString  $interface,
  Array[Eit_types::IPCIDR] $node_cidrs,
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

    '100 allow slurm controller traffic':
      dport => '1024-60535',
      ;
  }

  logrotate::rule { 'slurmd':
    ensure        => 'present',
    path          => "/var/log/slurm/*.log",
    rotate_every  => 'day',
    rotate        => 30,
    compress      => true,
    copy          => false,
    create        => false,
    delaycompress => true,
    missingok     => true,
  }

  include ::slurm::slurmd
}
