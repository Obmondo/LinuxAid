# Slurm slurm::slurmctld
class profile::computing::slurm::slurmdbd (
  Eit_types::SimpleString  $interface,
  Array[Eit_types::IPCIDR] $node_cidrs,
  String                   $db_buffer_pool_size,
  String                   $db_log_file_size,
  String                   $storagehost = '127.0.0.1',
) {

  firewall_multi {'100 allow slurmdbd':
    jump    => 'accept',
    iniface => $interface,
    source  => $node_cidrs,
    dport   => 6819,
    proto   => 'tcp',
  }

  firewall { '000 allow mysql connections':
    proto => 'tcp',
    dport => 3306,
    jump  => 'accept',
  }

  class { '::slurm::slurmdbd' :
    storagehost             => $storagehost,
    storagecharset          => 'utf8',
    storagecollate          => 'utf8_general_ci',
    innodb_buffer_pool_size => $db_buffer_pool_size,
    innodb_log_file_size    => $db_log_file_size,
  }
}
