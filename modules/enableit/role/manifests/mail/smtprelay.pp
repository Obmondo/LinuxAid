
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
# @param submission Also accept relay traffic on port 587 (submission). Same trust model as port 25: allowed_networks only, no auth. Defaults to false.
#
# @param myhostname The hostname for the relay.
#
# @param mydomain The domain for the relay. Defaults to undef.
#
# @param myorigin Optional domain appended to locally-posted mail. Defaults to undef, meaning postfix's own default ($myhostname) is used.
#
# @groups management manage.
#
# @groups relay relayhost, allowed_networks, submission.
#
# @groups interfaces myhostname, mydomain, myorigin.
#
class role::mail::smtprelay (
  Eit_types::Hostname                                 $myhostname,
  Optional[Eit_types::Domain]                         $mydomain,
  Boolean                                             $manage          = false,
  Optional[Eit_types::Domain]                         $myorigin        = undef,
  Optional[Eit_types::Host]                           $relayhost       = undef,
  Array[Variant[Eit_types::IP, Eit_types::IPCIDR]]    $allowed_networks = [],
  Boolean                                             $submission      = false,
) inherits ::role::mail {
  # Always trust loopback so locally-generated mail relays, then the
  # operator-supplied client networks.
  $mynetworks = ['127.0.0.0/8', '[::1]/128'] + $allowed_networks

  class { 'common::system::mail':
    manage          => $manage,
    relayhost       => $relayhost,
    mynetworks      => $mynetworks,
    inet_interfaces => 'all',
    myhostname      => $myhostname,
    mydomain        => $mydomain,
    myorigin        => $myorigin,
    submission      => $submission,
  }
}
