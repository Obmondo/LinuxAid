# @summary Class for managing OpenVMtools configuration within VMware virtualization
#
# @param manage Boolean parameter to control management of openvmtools. Defaults to false.
#
# @param ensure Whether to ensure the openvmtools package is installed and running. Defaults to false.
#
# @groups package_management manage, ensure
#
class common::software::openvmtools (
  Boolean $manage = false,
  Boolean $ensure = false,
) {

  if $manage {
    include ::profile::virtualization::vmware::openvmtools
  }
}
