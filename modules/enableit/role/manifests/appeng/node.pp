
# @summary Class for managing the Appeng Node role
#
# @param url The URL for the Node.js application. Defaults to undef.
#
# @param manage_repo Whether to manage the repository for Node.js. Defaults to false.
#
# @param repo The Node.js repository version. Defaults to '8.x'.
#
# @param version The version of Node.js to install. Defaults to 'present'.
#
# @groups url_management url.
#
# @groups repo_management repo, manage_repo, version.
#
class role::appeng::node (
  Eit_types::URL $url         = undef,
  Boolean        $manage_repo = false,
  Enum['12.x', '14.x', '16.x'] $repo = '8.x',
  Variant[Eit_types::Package_Ensure, Eit_types::Version] $version = 'present',
) inherits ::role::appeng {

  class { '::profile::nodejs':
    url         => $url,
    repo        => $repo,
    version     => $version,
    manage_repo => $manage_repo,
  }
}
