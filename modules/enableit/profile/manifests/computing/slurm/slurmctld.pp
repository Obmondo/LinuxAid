# Slurm slurm::slurmctld
class profile::computing::slurm::slurmctld (
  Eit_types::SimpleString   $interface,
  Array[Eit_types::IPCIDR]  $node_cidrs,
  Stdlib::Port              $slurmctldport,
  Eit_types::Slurm::Metrics $metrics,
  Eit_types::Version        $slurm_version,
) {

  $scrape_host = $::trusted['certname']

  firewall_multi {'100 allow slurmctld':
    jump    => 'accept',
    iniface => $interface,
    source  => $node_cidrs,
    dport   => $slurmctldport,
    proto   => 'tcp',
  }

  include ::slurm::slurmctld

  if versioncmp($slurm_version, '25.11') >= 0 {
    $metrics.each |$metric| {
      prometheus::scrape_job { "${metric}_${scrape_host}_${slurmctldport}":
        job_name    => 'slurm',
        collect_dir => '/etc/prometheus/file_sd_config.d',
        targets     => [ "${scrape_host}:${slurmctldport}" ],
        labels      => {
          'certname'         => $scrape_host,
          '__metrics_path__' => "/metrics/${metric}",
        },
      }
    }
  }
}
