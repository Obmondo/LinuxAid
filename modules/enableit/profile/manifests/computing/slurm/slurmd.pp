# Slurm slurm::slurmd
class profile::computing::slurm::slurmd (
  Eit_types::SimpleString  $interface,
  Array[Eit_types::IPCIDR] $node_cidrs,
  Optional[Integer[1]]     $slurmd_limit_nofile = undef,
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

  systemd::dropin_file { 'slurmd-90-nofile.conf':
    unit    => 'slurmd.service',
    filename => '90-nofile.conf',
    ensure  => $slurmd_limit_nofile ? {
      undef   => 'absent',
      default => 'present',
    },
    content => $slurmd_limit_nofile ? {
      undef   => undef,
      default => "[Service]\nLimitNOFILE=${slurmd_limit_nofile}\n",
    },
  }

  include ::slurm::slurmd
}
