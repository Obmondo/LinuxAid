# Class for managing virtualized servers
class common::virtualization (
  Boolean $treat_as_physical = $facts['virtual'] in ['kvm', 'physical', 'vmware', 'xenhvm', 'hyperv'],
) {

  if lookup('common::virtualization::vmware::openvmtools::ensure', Boolean, undef, false) {
    contain '::common::virtualization::vmware'
  }

}
