# Class for managing virtualized servers
class common::virtualization () {
  if lookup('common::virtualization::vmware::openvmtools::ensure', Boolean, undef, false) {
    contain '::common::virtualization::vmware'
  }
}
