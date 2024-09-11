# -*- mode: puppet; -*-
# Time-stamp: <Fri 2019-02-01 15:14 svarrette>
###########################################################################################
# Profile class used for setting up a Login node (cluster frontend/access)
#

class profiles::slurm::login
{
  include ::profiles::slurm
  include ::slurm::login
}
