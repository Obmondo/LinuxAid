# -*- mode: puppet; -*-
# Time-stamp: <Fri 2019-02-01 15:15 svarrette>
###########################################################################################
# Profile (base) class used for slurm general settings

class profiles::slurm
{
  #require ::slurm::params
  include ::slurm

}
