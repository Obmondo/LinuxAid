
# @summary Class for managing the Computing role
#
class role::computing () inherits ::role {

  contain 'role::computing::slurm'
}
