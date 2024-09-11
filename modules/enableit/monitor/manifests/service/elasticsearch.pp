# Elasticsearch
class monitor::service::elasticsearch (
  Boolean $enable = true,
  String  $record = $title,
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
