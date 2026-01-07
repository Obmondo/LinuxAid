# @summary Class for managing Slurm states
#
# @param enable Boolean to enable or disable the Slurm states. Defaults to true.
#
# @groups enable enable
#
class monitor::system::slurm (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::node_status":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
