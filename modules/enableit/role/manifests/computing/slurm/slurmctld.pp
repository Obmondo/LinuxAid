# @summary Controller settings for Slurm, used when `slurmctld` is enabled
#
# @param port The port slurmctld listens on. Defaults to 6817.
#
# @param metrics The Slurm metrics to export. Defaults to an empty array.
#
# @groups slurmctld port, metrics
#
class role::computing::slurm::slurmctld (
  Stdlib::Port              $port    = 6817,
  Eit_types::Slurm::Metrics $metrics = [],
) {
}
