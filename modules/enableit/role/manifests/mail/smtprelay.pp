
# @summary Class for managing a Postfix SMTP relay (smarthost)
#
# Sets up Postfix to relay all mail from a list of trusted client networks to a
# single upstream relay host. Trusted clients (matching `allowed_networks`) may
# relay to any destination; everything else is rejected by Postfix's default
# `reject_unauth_destination`.
#
# @param manage Whether to manage the relay. Defaults to false.
#
# @param relayhost Upstream host to relay all mail to (the smarthost). Required.
#
# @param allowed_networks List of client IPs/CIDRs permitted to relay through this server. Loopback is always allowed in addition to this list.
#
# @param inet_interfaces The interfaces Postfix should listen on. Defaults to 'all' so clients can reach it.
#
# @param myhostname The hostname for the relay.
#
# @param mydomain The domain for the relay. Defaults to undef.
#
# @param relay_domains Optional list of recipient domains to relay for (in addition to trusted-network relaying). Defaults to undef.
#
# @param noop_value A value for no-operation configurations. Defaults to undef.
#
# @groups management manage, noop_value.
#
# @groups relay relayhost, allowed_networks, relay_domains.
#
# @groups interfaces inet_interfaces, myhostname, mydomain.
#
class role::mail::smtprelay (
  Eit_types::Hostname                                 $myhostname,
  Optional[Eit_types::Domain]                         $mydomain,
  Boolean                                             $manage          = false,
  Optional[Eit_types::Host]                           $relayhost       = undef,
  Array[Variant[Eit_types::IP, Eit_types::IPCIDR]]    $allowed_networks = [],
  Variant[Eit_types::IP, Enum['all', 'localhost']]    $inet_interfaces = 'all',
  Optional[Array[Eit_types::Domain]]                  $relay_domains   = undef,
  Eit_types::Noop_Value                               $noop_value      = undef,
) {
  # Always trust loopback so locally-generated mail relays, then the
  # operator-supplied client networks.
  $mynetworks = ['127.0.0.0/8', '[::1]/128'] + $allowed_networks

  class { 'common::system::mail':
    manage          => $manage,
    relayhost       => $relayhost,
    mynetworks      => $mynetworks,
    relay_domains   => $relay_domains,
    inet_interfaces => $inet_interfaces,
    myhostname      => $myhostname,
    mydomain        => $mydomain,
    noop_value      => $noop_value,
  }
}
