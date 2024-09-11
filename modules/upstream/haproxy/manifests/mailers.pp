# @summary
#  This type will set up a mailers entry in haproxy.cfg on the load balancer.
# @note
#  This setting makes it possible to send emails during state changes.
#
#
# @param instance
#   Optional. Defaults to 'haproxy'.
#
# @param collect_exported
#   Boolean. Defaults to true.
#
define haproxy::mailers (
  Boolean $collect_exported = true,
  String  $instance         = 'haproxy',
) {
  # We derive these settings so that the caller only has to specify $instance.
  include haproxy::params
  if $instance == 'haproxy' {
    $instance_name = 'haproxy'
    $config_file = $haproxy::config_file
  } else {
    $instance_name = "haproxy-${instance}"
    $config_file = inline_template($haproxy::params::config_file_tmpl)
  }

  $parameters = {
    'name' => $name,
  }

  # Template uses: $name
  concat::fragment { "${instance_name}-${name}_mailers_block":
    order   => "40-mailers-00-${name}",
    target  => $config_file,
    content => epp('haproxy/haproxy_mailers_block.epp', $parameters),
  }

  if $collect_exported {
    haproxy::mailer::collect_exported { $name: }
  }
  # else: the resources have been created and they introduced their
  # concat fragments. We don't have to do anything about them.
}
