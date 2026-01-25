# @summary Class for managing cron jobs
#
# @param purge_unmanaged Whether to purge unmanaged jobs. Can be a boolean or 'root-only'. Defaults to false.
#
# @param jobs Hash of jobs to configure. Defaults to an empty hash.
#
# @groups management purge_unmanaged, jobs
#
class common::cron (
  Variant[Boolean, Enum['root-only']] $purge_unmanaged = false,
  Hash                                $jobs            = {},
) {
  include ::profile::cron
}
