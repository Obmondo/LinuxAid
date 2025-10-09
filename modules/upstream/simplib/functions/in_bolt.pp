# Returns ``true`` if the run is active inside of Bolt and ``false`` otherwise.
#
# Presently, this function is extremely basic. However, this check was placed
# here to allow us to update the check in the future without needing to modify
# more than one module or hunt down code.
#
# @return [Boolean]
#
function simplib::in_bolt {
  $environment == 'bolt_catalog'
}
