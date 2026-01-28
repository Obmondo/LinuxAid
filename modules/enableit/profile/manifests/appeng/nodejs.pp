# NodeJs Profile
class profile::nodejs (
  Stdlib::Httpurl $url,
  Boolean         $manage_repo             = false,
  Enum[
    '12.x',
    '14.x',
    '16.x'
  ]               $repo                    = '8.x',
  Variant[
    Eit_types::Package_Ensure,
    Eit_types::Version
  ]               $version                 = 'present',
  Boolean         $__package_allow_virtual = true,
) {

  # We need this here because the nodejs-dev and npm packages from the upstream
  # repo are virtual packages on Ubuntu 16.04. This causes Puppet to repeatedly
  # install `nodejs` and remove `nodejs-dev` (which is virtual, causing `nodejs`
  # to be removed instead) ad infinitum.
  #
  # I assume the situation to be similar on all Debian-based platforms, so let's
  # start with that.
  if $manage_repo {
    Package { allow_virtual => $__package_allow_virtual, }
  }

  class { '::nodejs':
    repo_url_suffix       => $repo,
    nodejs_package_ensure => $version,
    manage_package_repo   => $manage_repo,
  }
}
