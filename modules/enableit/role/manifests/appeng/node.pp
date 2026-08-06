
# @summary Class for managing the Appeng Node role
#
# @param repo The Node.js repository version. Defaults to '8.x'.
#
# @groups repo_management repo.
#
class role::appeng::node (
  Enum['12.x', '14.x', '16.x'] $repo = '8.x',
) inherits ::role::appeng {

  class { '::profile::appeng::nodejs':
    repo => $repo,
  }
}
