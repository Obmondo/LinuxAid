# Workaround for hiera accessing $trusted['certname']
$trustedcertname = $trusted['certname']

# Fix for undefined variables caused by
# https://github.com/puppetlabs/puppetlabs-puppet_agent/blob/caaa52fb3d080f277243c6e78ce842df71cdd146/manifests/install.pp#L191
$platform_tag = undef

# Pretty Print Subscription
$_pretty_subscription = pick($subscription, 'no')

# But it's only allowed with a subscription.
# $::obmondo_monitor defaults to true if there's a subscription for the given node
# and double check so one can not toggle monitoring from hiera
$obmondo_monitoring_status = ($facts['init_system'] == 'systemd')
and lookup('monitor::enable', Boolean, undef, $obmondo_monitor)
and $_pretty_subscription != 'no'

# Pretty Print Monitoring Status
$_monitoring_status = $obmondo_monitoring_status ? {
  true    => 'enabled',
  default => case $facts['init_system'] {
    'systemd': { 'disabled' }
    default: { "This system `${facts[init_system]}` is not supported for monitoring, disabling" }
  }
}

# Remove any classes that start with the knockout prefix `!!`. I'm not sure if
# this is smart...
$obmondo_classes = lookup('classes', Array[String], undef, []).functions::knockout

# Check if the given class is role::monitoring only.
# If role::monitoring is mixed with other class, then fail
if 'role::monitoring' in $obmondo_classes {
  if $obmondo_classes.size != 1 {
    fail("role::monitoring can not be included with other roles ${obmondo_classes.join(',')}")
  }
}

$_info_msg = @("EOT"/$n)

  Host: Running on '${trusted['certname']}'.
  Subscription Level: ${_pretty_subscription}
  Monitoring Status: ${_monitoring_status}
  Tags: ${obmondo_tags.delete_undef_values}
  Role: ${obmondo_classes}

  | EOT

info { $_info_msg: }

if $obmondo_classes.size == 1 {
  if $_pretty_subscription == 'no' {
    $_notify_msg =@("EOT"/$n)
      
    "Subscription is missing !!!

    The ${obmondo_classes.join(',')} will not be setup.
    Please add a subscription for server ${trusted['certname']} at https://obmondo.com

    | EOT
    info { $_notify_msg : }
  }
}

if $obmondo_classes.count > 2 {
  fail("More than 2 roles ${obmondo_classes.join(',')} are not currently allowed, please connect with obmondo.com support")
}

# Fail if more than one "unblendable" class is used at once.
#
# Because we're a bit special we only warn if the customer is EnableIT; however
# we should strive to fix this so that we can properly dogfood!
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

      Please contact info@enableit.dk if you believe this to be an error.
      | EOT

    if $obmondo['customer_id'] == 'enableit' {
      notify { $_msg:
        loglevel => 'err',
      }
    } else {
      fail($_msg)
    }
  }
}

node default {
  # Load role when no class is present, but tag is given
  if $obmondo_classes.empty and $obmondo_tags.delete_undef_values.size == 0 {
    $_role_msg = @("EOT"/$n)
      
      Missing role on ${trusted['certname']}

      Please add a role on https://obmondo.com/user/servers/add-server?certname=${trustedcertname}&isOldServer=true&step=2"

    | EOT
    info { $_role_msg : }
  }

  if $obmondo_monitoring_status {
    if $obmondo_classes.empty and $obmondo_tags.delete_undef_values.size > 0 {
      ::role.include
    } else {
      $obmondo_classes.include
    }
  }
}
