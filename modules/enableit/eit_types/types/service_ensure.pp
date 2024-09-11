# https://docs.puppet.com/puppet/latest/types/service.html#service-attribute-ensure
# (Property: This attribute represents concrete state on the target system.)
# 
# Whether a service should be running.
# 
# Valid values are stopped (also called false), running (also called true).
type Eit_types::Service_Ensure = Variant[Enum['stopped','running'],Boolean]
