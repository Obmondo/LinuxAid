# @summary Class for defining Prometheus monitoring thresholds
#
# @param record The name of the threshold record. Must start with 'monitor::'.
#
# @param enable Whether the threshold is enabled. Defaults to true.
#
# @param noop_value The noop value for the monitor. Defaults to $monitor::noop_value.
#
# @param expr The expression threshold. Defaults to 1.
#
# @param labels A hash of labels for the threshold. Defaults to {}.
#
# @param override Optional override for threshold parameters. Defaults to undef.
#
define monitor::threshold (
  String  $record     = $title,
  Boolean $enable     = true,
  Boolean $noop_value = $monitor::noop_value,
  Any     $expr       = 1,
  Hash    $labels     = {},

  Monitor::Override $override = undef,
) {
  unless $record =~ /^monitor::/ {
    fail('Invalid resource title; it should start with `monitor::`')
  }

  File {
    noop => $noop_value
  }

  $default_labels = {
    certname => $::trusted['certname']
  }
  + $labels
  + $override.dig('labels').lest || { {} }

  $_labels = $default_labels.map |$k, $v| {
    "${k}=\"${v}\""
  }.join(', ')

  $threshold_metric = if $override.empty {
    sprintf('threshold::%s{%s} %s', $record, $_labels, $expr)
  } else {
    if true in cron_range($override['crons']) {
      sprintf('threshold::%s{%s} %s', $record, $_labels, $override['expr'])
    } else {
      sprintf('threshold::%s{%s} %s', $record, $_labels, $expr)
    }
  }

  $textfile_dir = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)
  # NOTE: $name is used on purpose, so we can have same threshold in multiple files with diff labels
  $_fmt_alert_id = regsubst($name, '::', '_', 'G')
  $_filename = "${textfile_dir}/threshold_${_fmt_alert_id}.prom"

  $_threshold_metric = @("EOT"/$n)
# THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
# HELP threshold::${record} The threshold for ${record} alert
# TYPE threshold::${record} counter
${threshold_metric}
    | EOT

  file { $_filename:
    ensure  => file,
    owner   => 'node_exporter',
    group   => 'node_exporter',
    mode    => getvar('prometheus::config_mode'),
    content => $_threshold_metric,
  }
}
