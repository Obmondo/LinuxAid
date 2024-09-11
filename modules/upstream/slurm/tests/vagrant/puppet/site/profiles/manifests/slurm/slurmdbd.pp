# -*- mode: puppet; -*-
# Time-stamp: <Fri 2019-02-01 15:17 svarrette>
###########################################################################################
# Profile class used for setting up a Slurm DBD (DataBase Daemon) node
#

class profiles::slurm::slurmdbd {

  include ::profiles::slurm
  include ::slurm::slurmdbd

}
