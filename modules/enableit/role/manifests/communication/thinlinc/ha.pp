# @summary High availability settings for ThinLinc, used when `ha` is enabled
#
# @param loadbalancer_ip The IP address of the load balancer. Defaults to undef.
#
# @groups load_balancer loadbalancer_ip
#
class role::communication::thinlinc::ha (
  Optional[Stdlib::IP::Address] $loadbalancer_ip = undef,
) {
}
