# @summary Class for managing OpenVMtools configuration within VMware virtualization
#
# @param ensure Whether to ensure the openvmtools package is installed and running. Defaults to false.
#
# @param autoupgrade Whether to enable automatic upgrade of openvmtools. Defaults to true.
#
# @groups package_management ensure, autoupgrade
#
class common::virtualization::vmware::openvmtools (
  Boolean $ensure      = false,
  Boolean $autoupgrade = true,
) inherits common::virtualization::vmware {

  include ::profile::virtualization::vmware::openvmtools
}
