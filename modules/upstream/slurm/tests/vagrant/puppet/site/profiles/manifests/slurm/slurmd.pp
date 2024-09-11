# -*- mode: puppet; -*-
# Time-stamp: <Fri 2019-02-01 15:17 svarrette>
###########################################################################################
# Profile class used for setting up a Slurm Compute node
#

class profiles::slurm::slurmd
{
  include ::profiles::slurm
  include ::slurm::slurmd
}
