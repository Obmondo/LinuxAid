# @summary Returns whether the currently loaded OS is supported by the module
#
# This function uses the current facts to check if the current Operating System
# and its release or major release is supported.
#
# @param mod
#  The module name to check.
#
# @return Whether the current OS is supported for the given module
#
# @example Using the Puppet built in global $module_name
#   openvmtools::supported($module_name)
function openvmtools::supported(String[1] $mod) >> Boolean {
  $metadata = load_module_metadata($mod)
  $metadata['operatingsystem_support'].any |$os| {
    $os['operatingsystem'] == $facts['os']['name'] and $facts['os']['release']['major'] in $os['operatingsystemrelease']
  }
}
