# @summary Class for managing Visual Studio Code installation
#
# @param enable Boolean to determine if VSCode should be installed. Defaults to false.
#
# @param manage Boolean indicating whether to manage the vscode installation. Defaults to false.
#
# @param noop_value Optional boolean for noop mode. Defaults to undef.
#
class common::software::vscode (
  Boolean $enable     = false,
  Boolean $manage     = false,
  Eit_types::Noop_Value $noop_value = undef,
) inherits common {
  if $manage {
    contain profile::software::vscode
  }
}
