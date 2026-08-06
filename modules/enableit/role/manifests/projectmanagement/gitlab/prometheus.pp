# @summary Prometheus settings for GitLab, used when `prometheus` is enabled
#
# @param exporters The GitLab prometheus exporters to enable. Defaults to undef.
#
# @groups prometheus exporters
#
class role::projectmanagement::gitlab::prometheus (
  Optional[Eit_types::Gitlab::Prometheus_exporters] $exporters = undef,
) {
}
