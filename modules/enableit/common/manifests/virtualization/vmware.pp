# @summary Class for managing VMware virtualization setup
#
class common::virtualization::vmware {
  contain 'common::virtualization::vmware::openvmtools'
}
