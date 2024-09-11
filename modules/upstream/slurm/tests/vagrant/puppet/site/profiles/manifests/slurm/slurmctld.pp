# -*- mode: puppet; -*-
# Time-stamp: <Fri 2019-02-01 15:16 svarrette>
###########################################################################################
# Profile class used for setting up a Slurm Head node (where the slurmctld daemon runs)
#

class profiles::slurm::slurmctld
{
  include ::profiles::slurm
  include ::slurm::slurmctld
}
