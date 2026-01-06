# @summary Class for monitoring Elasticsearch service
#
# @param enable Boolean flag to enable or disable monitoring. Defaults to true.
#
# @param record The record name for the monitor. Defaults to the resource title.
#
# @groups monitor enable, record.
#
class monitor::service::elasticsearch (
  Boolean $enable = true,
  String $record  = $title,
) {
  @@monitor::alert { "${record}::TooFewNodesRunning":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${record}::ElasticsearchHeapTooHigh":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
