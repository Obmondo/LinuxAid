# Appeng Node role
class role::appeng::node (
  Eit_types::URL $url         = undef,
  Boolean        $manage_repo = false,
  Enum[
    '12.x',
    '14.x',
    '16.x'
  ]              $repo        = '8.x',
  Variant[
    Eit_types::Package_Ensure,
    Eit_types::Version
  ]              $version     = 'present',
) inherits ::role::appeng {

  class { '::profile::nodejs':
    url         => $url,
    repo        => $repo,
    version     => $version,
    manage_repo => $manage_repo,
  }
}
