# https://docs.puppet.com/puppet/latest/types/service.html#service-attribute-enable
# enable
#
# (Property: This attribute represents concrete state on the target system.)
#
# Whether a service should be enabled to start at boot. This property behaves quite
# differently depending on the platform; wherever possible, it relies on local
# tools to enable or disable a given service.
#
# Valid values are true, false, manual, mask.
type Eit_types::Service_Enable = Variant[Enum['manual','mask'],Boolean]
