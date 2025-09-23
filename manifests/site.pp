# Fix for undefined variables caused by
# https://github.com/puppetlabs/puppetlabs-puppet_agent/blob/caaa52fb3d080f277243c6e78ce842df71cdd146/manifests/install.pp#L191
$platform_tag = undef

# Remove any classes that start with the knockout prefix `!!`. I'm not sure if
# this is smart...
$obmondo_classes = lookup('classes', Array[String], undef, []).functions::knockout

# Check if the given class is role::monitoring only.
# If role::monitoring is mixed with other role, then fail
if 'role::monitoring' in $obmondo_classes {
  if $obmondo_classes.size != 1 {
    fail("role::monitoring can not be included with other roles ${obmondo_classes.join(',')}")
  }
}

if $obmondo_classes.count > 2 {
  fail("More than 2 roles ${obmondo_classes.join(',')} are not currently allowed, please connect with obmondo.com support")
}

# Fail if more than one "unblendable" class is used at once.
$obmondo_classes.filter |$_class| {
  !lookup("${_class}::__blendable", Boolean, undef, false)
}.then |$_obmondo_unblendable_classes| {
  if $_obmondo_unblendable_classes.count > 1 {
    $_unblendable_list = $_obmondo_unblendable_classes.map |$_c| {
      "+ ${_c}"
    }.join("\n")

    $_msg = @("EOT"/$n)
      ${_info_msg}

      More than 1 role that does not support mixing has been selected:
      ${_unblendable_list}

      Please contact ops@obmondo.com if you believe this to be an error.
      | EOT

    fail($_msg)
  }
}

# NOTE: monitoring will always be enabled by default, irrespective of the subs status
# User can enable/disable monitoring of a node, by adding settings in the hiera file
# ```yaml
# monitor::enable: true/false
# ```
$obmondo_monitoring_status = lookup('monitor::enable', Boolean, undef, true)

# Pretty Print Monitoring Status
$_monitoring_status = $obmondo_monitoring_status ? {
  true    => 'enabled',
  default => 'disabled',
}

$_has_tags = $obmondo_tags ? {
  Array   => $obmondo_tags,
  default => []
}

$_tags_info = unless $_has_tags.empty {
  @("EOT"/$n)
  Tags: ${obmondo_tags.delete_undef_values}
  | EOT
}

$_subs_info = if $subscription {
  @("EOT"/$n)
  Subscription Level: ${subscription}
  | EOT
}

$_node_info_msg = @("EOT"/$n)
  Host: Running on '${trusted['certname']}'.
  Monitoring Status: ${_monitoring_status}
${_tags_info}${_subs_info}Role: ${obmondo_classes}

  | EOT

info { $_node_info_msg: }

node default {
  # No class or tags is given, ask user to add it
  if $obmondo_classes.empty and $_has_tags.size == 0 {
    $_role_msg = @("EOT"/$n)

      Missing role on ${trusted['certname']}
      Please add a role on https://obmondo.com/user/servers/add-server?certname=${trusted['certname']}&isOldServer=true&step=2"
      or
      Add the role in linuxaid-config/agents/${trusted['certname']}.yaml
    | EOT

    info { $_role_msg: }
  }

  # Load default role when no class is given and has no tags
  if $obmondo_classes.empty and $_has_tags.size > 0 {
    ::role.include
  }

  # Load the given role give in the hiera
  if !$obmondo_classes.empty {
    $obmondo_classes.include
  }
}
