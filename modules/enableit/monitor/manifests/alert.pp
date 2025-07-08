# Prometheus monitoring alert
#
# @param alert_id The identifier for the alert. Defaults to $title.
#
# @param enable Whether the alert is enabled. Defaults to true.
#
# @param noop_value The noop value used in monitoring. Defaults to $monitor::noop_value.
#
# @param disable Optional disable configuration.
#
define monitor::alert (
  String  $alert_id   = $title,
  Boolean $enable     = true,
  Boolean $noop_value = $monitor::noop_value,
  Monitor::Disable $disable = undef,
) {

  unless $alert_id =~ /^monitor::/ {
    fail('Invalid alert ID; it should start with `monitor::`')
  }

  File {
    noop => $noop_value,
  }

  $default_labels = {
    certname => $::trusted['certname'],
    alert_id => $alert_id,
  }

  $_labels = $default_labels.map |$k, $v| {
    "${k}=\"${v}\""
  }.join(', ')

  $threshold_metric = if $disable.empty {
    sprintf('obmondo_monitoring{%s} %s', $_labels, Integer($enable))
  } else {
    if true in cron_range($disable['crons']) {
      sprintf('obmondo_monitoring{%s} 0', $_labels)
    } else {
      sprintf('obmondo_monitoring{%s} %s', $_labels, Integer($enable))
    }
  }

  $textfile_dir = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)
  $expr = Integer($enable)
  $_fmt_alert_id = regsubst($alert_id, '::', '_', 'G')
  $_filename = "${textfile_dir}/obmondo_monitoring_${_fmt_alert_id}.prom"

  $_threshold_metric = @("EOT"/$n)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    # HELP obmondo_monitoring The toggle for the respective alert_id
    # TYPE obmondo_monitoring counter
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
