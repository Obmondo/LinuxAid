# Returns whether or not the passed module is blacklisted per the module's
# metadata.json.
#
# If a blacklist is passed, then it will return `false` if the OS is in the
# blacklist and `true` otherwise.
#
# @param module_metadata
#   A Hash of the contents of the metadata.json for a puppet module.
#
#   * In general, this should be generated by load_module_metadata($module_name)
#
# @param blacklist
#   An Array of Strings or Hashes
#
#   * Strings: Only match against the OS name, effectively blacklisting
#     all versions of the OS
#   * Hash: Must be of the form { 'OS' => ['version1', 'version2'] }
#
#   @example Blacklist all Windows, RHEL 7.2, and OEL 6.4
#     [ 'Windows', { 'RedHat' => ['7.2'] }, { 'OracleLinux' => ['6.4'] ]
#
# @param options
#   Options that determine the nature of OS matching
#
#   Attributes:
#     release_match:
#        * 'none'  -> No match on release (default)
#        * 'full'  -> Full release must match
#        * 'major' -> Only the major release must match
#
# @return [Boolean]
#   true  => The OS + release is blacklisted
#   false => The OS + release is not not blacklisted
#
function simplib::module_metadata::os_blacklisted (
  Hash $module_metadata,
  Array[Variant[String[1], Hash[String[1], Variant[String[1], Array[String[1]]]]]] $blacklist,
  Optional[Struct[{
    release_match => Enum['none','full','major']
  }]] $options = undef
) >> Boolean {

  $_default_options = { 'release_match' => 'none' }

  if $options {
    $_options = deep_merge($_default_options, $options)
  }
  else {
    $_options = $_default_options
  }

  if !$module_metadata['operatingsystem_support'] or empty($module_metadata['operatingsystem_support']) {
    debug("'operatingsystem_support' was not found in module '${module_name}'")

    $result = false
  }

  unless defined('$result') {
    $result = $blacklist.reduce(false) |$memo, $os_info| {
      if $os_info =~ String {
        $_os_name = $os_info
        $_os_versions = undef
      }
      else {
        $_os_name = keys($os_info)[0]

        # This could be a number so we have to force the Array cast
        $_os_versions = Array($os_info[$_os_name], true)
      }

      if $_os_name == $facts['os']['name'] {
        if $_os_versions {
          $memo or case $_options['release_match'] {
            'full': {
              $facts['os']['release']['full'] in $_os_versions
            }
            'major': {
              $_os_major_releases = $_os_versions.map |$os_release| { split($os_release, '\.')[0] }

              $facts['os']['release']['major'] in $_os_major_releases
            }
            default: { true }
          }
        }
        else {
          true
        }
      }
      else { false or $memo }
    }
  }

  unless defined('$result') { $result = false }

  $result
}
