# @summary Accounting database settings for Slurm, used when `slurmdbd` is enabled
#
# @param buffer_pool_size The InnoDB buffer pool size for slurmdbd. Defaults to '256M'.
#
# @param log_file_size The InnoDB log file size for slurmdbd. Defaults to '24M'.
#
# @groups slurmdbd buffer_pool_size, log_file_size
#
class role::computing::slurm::slurmdbd (
  String $buffer_pool_size = '256M',
  String $log_file_size    = '24M',
) {
}
