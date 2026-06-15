# @summary Class for managing Slurm states
#
# @param enable Boolean to enable or disable the Slurm states. Defaults to true.
#
# @groups enable enable
#
class monitor::system::slurm (
  Boolean $enable = true,
) {
  $alerts = [
    'job_failed',
    'nodes_down',
    'jobs_pending',
    'node_drain',
    'node_error',
  ]

  $alerts.each |$alert| {
    @@monitor::alert { "${title}::${alert}":
      enable => $enable,
      tag    => $::trusted['certname'],
    }
  }
}
