# Fails a compile if the client system is not compatible with the module's
# `metadata.json`
#
# NOTE: New capabilities will be added to the simplib::module_metadata::assert
# function instead of here but this will remain to preserve backwards
# compatibility
#
# @param module_name
#   The name of the module that should be checked
#
# @param options
#   Behavior modifiers for the function
#   * Can be set using `simplib::assert_metadata::options` in the `lookup`
#     stack
#
#   **Options**
#
#   * enable    => If set to `false` disable all validation
#   * os
#       * validate => Whether or not to validate the OS settings
#       * options
#           * release_match
#             * none  -> No match on minor release (default)
#             * full  -> Full release must match
#             * major -> Only the major release must match
#
# @return [None]
#
function simplib::assert_metadata (
  String[1] $module_name,
  Optional[Struct[{
    enable    => Optional[Boolean],
    os        => Optional[Struct[{
      validate => Optional[Boolean],
      options  => Optional[Struct[{
        release_match => Enum['none','full','major']
      }]]
    }]]
  }]]       $options = simplib::lookup('simplib::assert_metadata::options', { 'default_value' => undef }),
) {

  $_default_options = {
    'enable'    => true,
    'os'        => {
      'validate' => true,
      'options'  => {
        'release_match' => 'none'
      }
    }
  }

  if $options {
    $_tmp_options = deep_merge($_default_options, $options)
  }
  else {
    $_tmp_options = $_default_options
  }

  $_options = {
    'enable'        => $_tmp_options['enable'],
    'os_validation' => {
      'enable'  => $_tmp_options['os']['validate'],
      'options' => $_tmp_options['os']['options']
    }
  }

  if $_options['enable'] {
    $_module_metadata = load_module_metadata($module_name)

    if empty($_module_metadata) {
      fail("Could not find metadata for module '${module_name}'")
    }

    if $_options['os_validation']['enable'] {
      unless simplib::module_metadata::os_supported($_module_metadata, $_options['os_validation']['options']) {
        fail("OS '${facts['os']['name']} ${facts['os']['release']['full']}' is not supported by '${module_name}'")
      }
    }
  }
}
