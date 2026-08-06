# NodeJs Profile
class profile::appeng::nodejs (
  Enum[
    '12.x',
    '14.x',
    '16.x'
  ] $repo = '8.x',
) {

  class { '::nodejs':
    repo_url_suffix       => $repo,
    nodejs_package_ensure => 'present',
    manage_package_repo   => false,
  }
}
