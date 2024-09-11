# OpenVMtools
class common::virtualization::vmware::openvmtools (
  Boolean $ensure      = false,
  Boolean $autoupgrade = true,
) inherits common::virtualization::vmware {

  include ::profile::virtualization::vmware::openvmtools
}
