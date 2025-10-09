# Fails a compile if the client system is not compatible with the module's
# `metadata.json`
#
# @param module_name
#   The name of the module that should be checked
#
# @param options
#   Options to control the assertion behavior
#
#   @see $simplib::module_metadata::os_blacklist::options
#   @see $simplib::module_metadata::os_supported::options
#
# @return [None]
#
function simplib::module_metadata::assert (
  String[1] $module_name,
  Optional[Struct[{
    enable => Optional[Boolean],
    blacklist => Optional[Array[Variant[String[1], Hash[String[1], Variant[String[1], Array[String[1]]]]]]],
    blacklist_validation => Optional[Struct[{
      enable => Optional[Boolean],
      options  => Optional[Struct[{
        release_match => Enum['none','full','major']
      }]]
    }]],
    os_validation => Optional[Struct[{
      enable => Optional[Boolean],
      options => Optional[Struct[{
        release_match => Enum['none','full','major']
      }]]
    }]]
  }]] $options = simplib::lookup('simplib::assert_metadata::options', { 'default_value' => undef })
) {

  $_default_options = {
    'enable' => true,
    'blacklist_validation' => {
      'enable' => true
    },
    'os_validation' => {
      'enable' =>  true
    }
  }

  if $options {
    $_options = deep_merge($_default_options, $options)
  }
  else {
    $_options = $_default_options
  }

  if $_options['enable'] {
    $_module_metadata = load_module_metadata($module_name)

    if empty($_module_metadata) {
      fail("Could not find metadata for module '${module_name}'")
    }

    if $_options['blacklist_validation']['enable'] and $_options['blacklist'] {
      if simplib::module_metadata::os_blacklisted($_module_metadata, $_options['blacklist'], $_options['blacklist_validation']['options']) {
        $_caller = simplib::caller()
        fail("OS '${facts['os']['name']} ${facts['os']['release']['full']}' is not supported at '${_caller}'")
      }
    }

    if $_options['os_validation']['enable'] {
      unless simplib::module_metadata::os_supported($_module_metadata, $_options['os_validation']['options']) {
        fail("OS '${facts['os']['name']} ${facts['os']['release']['full']}' is not supported by '${module_name}'")
      }
    }
  }
}
