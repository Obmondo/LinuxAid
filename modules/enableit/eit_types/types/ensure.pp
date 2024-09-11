# https://docs.puppet.com/puppet/latest/type.html
# ensure
# 
# (Property: This attribute represents concrete state on the target system.)
# 
# The basic property that the resource should be in.
# 
# Valid values are present, absent.
type Eit_types::Ensure = Enum['present','absent']
